class Restaurant < ApplicationRecord

  include EsRecord
  include EsRecord::InstanceMethods
  include EsCrudConcern
  include CrudConcern

  self.primary_key = 'es_id'

  def self.to_s
    'Restaurant'
  end

  def self.es_type_name
    'restaurants'
  end

  attr_accessor :name, :address , :location, :description, :discount, :cuisines, :rating, :min_price, :max_price, :tags

  validate :validate_restaurant

  #elastic attributes for field mapping
  def self.es_attributes
    {
      name: { type: 'keyword'},
      address: { type: 'keyword' },
      location: { type: 'keyword'},
      description: { type: 'keyword'},
      discount: { type: 'keyword'},
      cuisines: { type: 'keyword'},
      rating: { type: 'float' },
      min_price: { type: 'integer'},
      max_price: { type: 'integer' },
      tags: { type: 'keyword' }
    }
  end

  def setup_defaults
    super
  end

  def get_indexed_attributes
    indexed_attributes = {
      name: name,
      address: address,
      location: location,
      description: description,
      discount: discount,
      cuisines: cuisines,
      rating: rating,
      min_price: min_price,
      max_price: max_price,
      tags: tags
    }
    indexed_attributes.merge(super)
  end

  #populates search content
  def search_content
    content = tags
    content.join(", ") + ", #{name}"
  end

  #filters available for the resource
  def self.filters
    [
      {
        name: 'price_range',
        label: 'Price Range',
        type: 'range',
        es_type: 'integer',
        options: {
          field: ['min_price', 'max_price']
        }
      },
      {
        name: 'rating',
        label: 'Rating',
        type: 'range',
        es_type: 'integer',
        options: {
          field: 'rating',
        }
      },
      {
        name: 'location',
        label: 'Location',
        type: 'checkbox',
        es_type: 'keyword',
        options: {
          field: 'location',
          labels: {
            'chennai' => 'Chennai',
            'maduari' => 'Maduari',
            'salem' => 'Salem',
            'karaikudi' => 'Karakudi',
            'bangalore' => 'Bangalore' 
          }
        }
      },
      {
        name: 'cuisines',
        label: 'Cuisine',
        type: 'checkbox',
        es_type: 'keyword',
        options: {
          field: 'cuisine_type',
          labels: {
            'any' => 'Any',
            'american' => 'American',
            'italian' => 'Italian',
            'french' => 'French',
            'indian' => 'Indian',
            'arbian' => 'Arabian',
            'chinese' => 'Chinese',
            'japanese' => 'Japanese'
          }
        }
      }
    ]
  end

  #field for sort section
  def self.headers
    [
      {
        field: 'rating',
        labels: 'Rating',
        allowed_sort_options: ['desc','asc'],
        sorted_by: 'desc'
      },
      {
        field: 'price',
        labels: 'Price',
        allowed_sort_options: ['desc','asc']
      }
    ]
  end

  def get_basic_resource_data
    {
      name: name,
      address: address,
      description: description,
      discount: discount,
      cuisines: cuisines,
      rating: rating,
      min_price: min_price,
      max_price: max_price
    }
  end

  #return the hash for front_end to display
  def get_items_for_list(restricted_attributes: [])
    items_for_list = {
      id: id,
      name: name,
      location: location,
      address: address,
      description: description,
      discount: discount,
      cuisines: cuisines,
      rating: rating,
      min_price: min_price,
      max_price: max_price
    }
    return items_for_list
  end

  #perform validation
  def validate_restaurant
    validate_empty_fields
    validate_name
  end

  def validate_empty_fields
    errors.add(:name, :blank) if name.not_present?
    errors.add(:address, :blank) if address.not_present?
    errors.add(:location, :blank) if location.not_present?
    errors.add(:description, :blank) if description.not_present?
    errors.add(:cuisines, message: "Cuisine can't be empty") if cuisines.empty?
    errors.add(:rating, :blank) if !rating.present?
    errors.add(:min_price, :blank) if !min_price.present?
    errors.add(:max_price, :blank) if !max_price.present?
  end

  def validate_name
    if name.present?
      must_conditions = [{
        bool: {
          must: [
            { term: { name: self.name } }
          ]
        }
      }]
      if !self.new_record?
        must_conditions[0][:bool][:must_not] = [{ term: { _id: id } }]
      end
      errors.add(:name, message: "Same restaurnt name can't be given again") if Restaurant.get_count(must_conditions) > 0
    end
  end

  #Creating records from the data given in initializer
  def self.seed_restaurant_data
    $restaurants.each do |params|
      restaurant = Restaurant.new(params)
      restaurant.save
    end
  end

end