# coding: utf-8

module EsRecord
  extend ActiveSupport::Concern

  # core
  attr_accessor :data_version

  #crud
  attr_accessor :created_at, :updated_at, :search_english, :search_prefix, :search_standard

  module ClassMethods

    def current_data_version_number
      1
    end

    def perform_data_version_migrations(attrs, data_version)
      return attrs, data_version
    end

    #returns the name of elastic index to be created
    def index_name(version)
      "#{es_type_name}-v-#{version}"
    end

    #type of the elastic index
    def es_type_name
      self.name.pluralize.downcase
    end

    #formats the body of elastic query
    def get_query_body conditions, must_not_conditions = []
      query_body = {
        bool: {
          must: conditions
        }
      }
      query_body[:bool][:must_not] = must_not_conditions if must_not_conditions.any?
      query_body
    end

    #formats query for searching in the index
    def get_search_body conditions, sort, per_page, page
      query_body = get_query_body(conditions)
      size = per_page
      from_index = (page.to_i - 1) * size.to_i
      {
        query: query_body,
        from: from_index,
        size: size,
        sort: sort
      }
    end
    
    #retruns specified page and count
    def search must_conditions = [], sort = [], per_page = 25, page = 1
      must_conditions = [must_conditions] if !must_conditions.kind_of?(Array)
      body = get_search_body(must_conditions, sort, per_page, page)
      search_response = $es.search(index: es_type_name, type: es_type_name, body: body)
      return instantiate_results(search_response), search_response['hits']['total']
    end

    #returns count for conditions given
    def get_count conditions = []
      resp = $es.search(index: es_type_name, type: es_type_name, body: {
        query: get_query_body(conditions),
        size: 0
      })
      return resp['hits']['total']
    end

    def instantiate_results es_response
      es_response['hits']['hits'].collect do |hit|
        instance = instantiate_result(hit)
      end
    end

    #creating instance of class object
    def instantiate_result es_hit
      data_parsed, new_version_number = self.perform_data_version_migrations(JSON.parse(es_hit['_source']['data_json']), es_hit['_source']['data_version'])
      instance = self.new(data_parsed, es_hit['_id'])
      instance.data_version = new_version_number
      instance.after_find
      instance
    end

    #return the instance of the document found from the index
    def find(id, ignore: [])
      hit = es_get(id, ignore: ignore)
      if hit['found']
        result = instantiate_result(hit)
        return result
      end
      false
    end

    #returns the elastic document from the index
    def es_get(id, ignore: [])
      $es.get(index: es_type_name, type: es_type_name, id: id, ignore: ignore)
    end

    #analysis used for index
    def default_analysis
      {
        filter: {
          english_possessive_stemmer: {
            type: 'stemmer',
            language: 'possessive_english'
          },
          english_keywords: {
            type: 'keyword_marker',
            keywords: ['colourful', 'colorful', 'lining']
          },
          minimal_english_stemmer: {
            type: 'stemmer',
            language: 'minimal_english'
          },
          english_stop: {
            type: 'stop',
            stopwords: '_english_'
          },
          prefix_matcher: {
            type: 'edge_ngram',
            min_gram: 1,
            max_gram: 30
          }
        },
        analyzer: {
          dashboard_search_prefix: {
            type: 'custom',
            tokenizer: 'standard',
            filter: [
              'lowercase',
              'prefix_matcher'
            ]
          },
          dashboard_search_standard: {
            type: 'standard'
          },
          dashboard_search_english: {
            type: 'custom',
            tokenizer: 'standard',
            filter: [
              'english_possessive_stemmer',
              'lowercase',
              'english_stop',
              'english_keywords',
              'minimal_english_stemmer'
            ]
          }
        }
      }
    end

    #common elastic attributes
    def es_attributes
      {
        data_version: { type: 'integer' },
        created_at: { type: 'date', format: 'basic_date_time_no_millis' },
        updated_at: { type: 'date', format: 'basic_date_time_no_millis' },
        search_standard: { type: 'text', analyzer: 'dashboard_search_standard' },
        search_english: { type: 'text', analyzer: 'dashboard_search_english' },
        search_prefix: { type: 'text', analyzer: 'dashboard_search_prefix', search_analyzer: 'dashboard_search_standard' }
      }
    end

    #return body for index creation
    def create_index_body
      index_body = {
        settings: {
          index: {
            number_of_shards: 1,
            number_of_replicas: 2,
            analysis: default_analysis
          }
        },
        mappings: {
          "#{es_type_name}": {
            dynamic_templates: [
              { keywords: { match: '_keyword_*', mapping: { type: 'keyword' } } },
              { floats: { match: '_float_*', mapping: { type: 'float' } } },
              { booleans: { match: '_boolean_*', mapping: { type: 'boolean' } } },
              { datetimes: { match: '_datetime_*', mapping: { type: 'date', format: 'basic_date_time_no_millis' } } }
            ],
            properties: es_attributes.merge(es_attributes)
          }
        }
      }
    end

    #creates elastic index
    def create_index(version)
      $es.indices.create index: index_name(version), body: create_index_body
    end

    #destroys the elastic index
    def destroy_index(version)
      $es.indices.delete index: index_name(version), ignore: [404]
    end

    def new(params = {}, id = false)
      attrs = params.to_h.deep_symbolize_keys
      attrs.merge!(id: id) if id.present?
      super(attrs)
    end

    #creates the index and set alias name for the index
    def create_main_index(version = 1)
      self.create_index(version)
      self.set_alias(version)
    end

    def set_alias(version, remove_version = false)
      if remove_version.eql?(false)
        $es.indices.update_aliases body: {
          actions: [
            { add: { index: index_name(version), alias: es_type_name } }
          ]
        }
      else
        $es.indices.update_aliases body: {
          actions: [
            { remove: { index: index_name(remove_version), alias: es_type_name } },
            { add: { index: index_name(version), alias: es_type_name } }
          ]
        }
      end
    end

    def update_index_mappings mappings = nil
      if mappings.nil?
        mappings = create_index_body[:mappings]
      else
        mappings = JSON.parse(mappings).deep_symbolize_keys
      end
      mappings.each do |mapping_type, mapping_details|
        $es.indices.put_mapping index: es_type_name, type: mapping_type, body: mapping_details
      end
    end

    def get_index_mappings
      create_index_body[:mappings].to_json
    end

    def get_resource_ids must_conditions = [], must_not_conditions = []
      batch_size = 10000
      body = {
        size: batch_size,
        _source: false,
        query: get_query_body(must_conditions, must_not_conditions)
      }
      response = $es.search index: es_type_name, type: es_type_name, body: body
      response['hits']['hits'].collect { |hit| hit['_id'] }
    end

    def count
      response = $es.search index: es_type_name, type: es_type_name, body: { size: 0, query: { match_all: { } } }
      response['hits']['total']
    end

    #return last record of the index based on created_at
    def last
      response = $es.search index: es_type_name, type: es_type_name, body: { size: 1, query: { match_all: { } }, sort: [{created_at: 'desc'}] }
      mpages = instantiate_results(response)
      mpages.last
    end

    #return first record of the index based on created_at
    def first
      response = $es.search index: es_type_name, type: es_type_name, body: { size: 1, query: { match_all: { } }, sort: [{created_at: 'asc'}] }
      mpages = instantiate_results(response)
      mpages.last
    end

    #default filters
    def filters
      [
        {
          name: 'created_at',
          label: 'Created at',
          type: 'daterange',
          es_type: 'datetime',
          options: {
            field: 'created_at'
          }
        },
        {
          name: 'updated_at',
          label: 'Updated at',
          type: 'daterange',
          es_type: 'datetime',
          options: {
            field: 'updated_at'
          }
        }
      ]
    end

  end

  module InstanceMethods

    #sets the default values for attributes
    def setup_defaults
      self.data_version = self.class.current_data_version_number if !data_version
      if created_at.present? and created_at.kind_of?(String)
        self.created_at = Time.parse(created_at).utc
      end
      if updated_at.present? and updated_at.kind_of?(String)
        self.updated_at = Time.parse(updated_at).utc
      end
    end

    def after_find
      self
    end
    #overridden in resource model
    def get_indexed_attributes
      {
        data_version: data_version || self.class.current_data_version_number
      }.merge(self.get_crud_attributes)
    end
    #overridden in resource model
    #converted to json while saving
    def get_non_indexed_attributes
      {}
    end

    def get_save_attributes(touch = true)
      self.touch if touch
      indexed_attributes = self.get_indexed_attributes
      attributes = indexed_attributes.merge({
        data_json: self.get_all_attributes.to_json
      })
      attributes
    end

    #updates the updated_at time for the record, sets created_at time for new_record
    def touch
      now = Time.current.utc
      self.updated_at = now
      self.created_at = now if new_record?
    end

    def get_crud_attributes
      crud_attributes = {
        search_prefix: self.search_content,
        search_english: self.search_content,
        search_standard: self.search_content
      }
      if created_at
        crud_attributes[:created_at] = created_at.strftime('%Y%m%dT%H%M%S%z')
      end
      if updated_at
        crud_attributes[:updated_at] = updated_at.strftime('%Y%m%dT%H%M%S%z')
      end
      crud_attributes
    end

    #overridden in resource model
    #field used for search
    def search_content
      ''
    end

    def get_all_attributes
      data_json = {}
      data_json.merge!(self.get_indexed_attributes)
      data_json.merge!(self.get_non_indexed_attributes)
      data_json
    end

    #callbacks
    def before_es_save
      true
    end

    #callbacks
    def after_es_save
      true
    end

    #callbacks
    def before_es_update
      true
    end

    def to_s
      name
    end

    #validates and save the records
    #performs any callbacks
    def save(touch: true)
      if valid?
        before_es_save
        if self.new_record?
          response = $es.index index: self.class.es_type_name, type: self.class.es_type_name, body: self.get_save_attributes(touch)
          self.id = response['_id']
          @id = response['_id']
        else
          $es.index index: self.class.es_type_name, type: self.class.es_type_name, id: id, body: self.get_save_attributes(touch)
        end
        # after_es_save always returns true
        after_es_save
      else
        false
      end
    end

    #callbacks
    def before_destroy
      true
    end

    #callbacks
    def after_destroy
      true
    end

    def new_record?
      !self.id.present?
    end

    #destroy the record
    def destroy
      return false if !self.before_destroy
      $es.delete index: self.class.es_type_name, type: self.class.es_type_name, id: id
      self.after_destroy
      true
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      Logger.new("log/restaurant_destroyer.log").error "EsUnifiedStoreRecord: 404 while destroying restaurant: #{id}"
      true
    end
  end

end