module EsCrudConcern
  extend ActiveSupport::Concern
  module ClassMethods

    #return the paginated response for index page
    def get_results_and_filters_from_params(params, conditions, filters, restricted_headers = [], must_not_conditions = [], source = true)
      if params[:search] and params[:search].present?
        conditions << {
          bool: {
            should: [
              { match: { search_english: { query: params[:search], operator: 'and' } } },
              { match: { search_prefix: { query: params[:search], operator: 'and' } } }
            ],
            minimum_should_match: 1
          }
        }
      end
      if params['sort']
        selected_sort_order = params['sort'].permit!.to_h
      else
        selected_sort_order = get_default_sort_order
      end
      selected_sort_order.deep_stringify_keys!
      sort_order = [
        {
          selected_sort_order['field'] => {
            order: selected_sort_order['direction'],
            missing: (selected_sort_order['direction'].eql?('asc') ? '_first' : '_last' )
          }
        }
      ]
      if params.has_key?(:filters)
        applied_filters = params[:filters].permit!.to_h
      else
        applied_filters = {}
      end

      page = (params[:page] || 1).to_i
      per_page = [(params[:per_page] || 25).to_i, 1000].min
      size = per_page
      from_index = (page.to_i - 1) * size.to_i
      filter_conditions = get_filter_conditions(filters, applied_filters)
      aggs_for_filters = filters.collect do |filter|
        other_filter_conditions = filter_conditions.except(filter[:name]).values
        if filter[:options][:field].is_a? Array
          filter_copy = filter.deep_dup
          aggs_for_fields = filter[:options][:field].collect do |field|
            filter_copy[:name], filter_copy[:options][:field] = field, field
            agg_for_filter = get_agg_for_filter(filter_copy)
            format_agg_for_filter_based_on_filter_condition(filter_copy[:name], other_filter_conditions, agg_for_filter)
          end.inject(&:merge)
          aggs_for_fields
        else
          agg_for_filter = get_agg_for_filter(filter)
          format_agg_for_filter_based_on_filter_condition(filter[:name], other_filter_conditions, agg_for_filter)
        end
      end.inject(&:merge)

      es_body = {
        query: {
          bool: {
            must: conditions
          }
        },
        from: from_index,
        size: size,
        sort: sort_order,
        aggs: aggs_for_filters || {}
      }
      es_body[:query][:bool][:must_not] = must_not_conditions if must_not_conditions.any?
      post_filters = filter_conditions.values
      if post_filters.any?
        es_body[:post_filter] = { bool: { must: post_filters } }
      end
      es_body[:_source] = source
      es_response = $es.search index: es_type_name, type: es_type_name, body: es_body
      response = {
        headers: headers_with_selection(selected_sort_order, except: restricted_headers),
        filters: filters,
        current_page: page,
        per_page: per_page,
        total: es_response['hits']['total'],
        total_pages: (es_response['hits']['total'].to_f / per_page).ceil
      }
      results = es_response
      if source.eql?(true)
        results = instantiate_results(es_response)
      end
      return results, response
    end

    def array_item_by_key_value array_of_hashes, key, value
      array_of_hashes.select{|item| item[key].eql?(value) }.first
    end

    def format_agg_for_filter_based_on_filter_condition filter_name, other_filter_conditions, agg_for_filter
      if other_filter_conditions.any?
        { filter_name => { filter: { bool: { must: other_filter_conditions } }, aggs: agg_for_filter } }
      else
        agg_for_filter
      end
    end

    #formats filter conditions based on filters applied
    def get_filter_conditions(filters, applied_filters)
      return {} if applied_filters.empty?
      filter_conditions = {}
      applied_filters.each do |applied_filter_key, applied_filter_values|
        applied_filter_details = array_item_by_key_value(filters, :name, applied_filter_key)
        case applied_filter_details[:es_type]
        when 'keyword'
          filter_conditions[applied_filter_details[:name]] = { terms: { applied_filter_details[:options][:field] => applied_filter_values } }
        when 'bool'
          filter_conditions[applied_filter_details[:name]] = { term: { applied_filter_details[:options][:field] => applied_filter_values } }
        when 'integer'
          if applied_filter_details[:options][:field].is_a? Array
            filter_conditions[applied_filter_details[:options][:field][0]] = { range: { applied_filter_details[:options][:field][0] => { gte: applied_filter_values[0] } } }
            filter_conditions[applied_filter_details[:options][:field][1]] = { range: { applied_filter_details[:options][:field][1] => { lte: applied_filter_values[1] } } }
          else
            filter_conditions[applied_filter_details[:name]] = { range: { applied_filter_details[:name] => { gte: applied_filter_values[0], lte: applied_filter_values[1] } } }
          end
        when 'datetime'
          min = Time.parse("#{Time.parse(applied_filter_values[0]).strftime('%Y/%m/%d %H:%M:%S')} #{"UTC"}").utc.strftime('%Y%m%dT%H%M%S%z')
          max = Time.parse("#{Time.parse(applied_filter_values[1]).strftime('%Y/%m/%d %H:%M:%S')} #{"UTC"}").utc.strftime('%Y%m%dT%H%M%S%z')
          filter_conditions[applied_filter_details[:name]] = { range: { applied_filter_details[:name] => { gte: min, lte: max } } }
        end
      end
      filter_conditions
    end

    def get_agg_for_filter(filter)
      case filter[:es_type]
      when 'bool', 'keyword'
        agg = { filter[:name] => { terms: { field: filter[:name] } } }
      when 'datetime', 'integer'
        agg = { filter[:name] => { stats: { field: filter[:name] } } }
      end
      return agg
    end

  end
end