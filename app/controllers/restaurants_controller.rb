class RestaurantsController < ApplicationController

  def index
    conditions = []
    results, response = Restaurant.get_results_and_filters_from_params(params, conditions, Restaurant.filters)
    items = results.map {|r|r.get_items_for_list(restricted_attributes: [])}
    render :json => response.merge(items: items)
  end
  
end