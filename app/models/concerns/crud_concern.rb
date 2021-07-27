module CrudConcern
  extend ActiveSupport::Concern
  
  module ClassMethods

    #return the default sort_order from the resource model
    def get_default_sort_order
      default_sort_order = self.headers.select{ |h| h[:sorted_by] ? true : false }.first
      default_sort_order.merge(direction: default_sort_order[:sorted_by])
    end

    #return the sort section with selected sort_order
    def headers_with_selection selected_sort, except: [], headers: nil
      headers ||= self.headers
      all_headers = []
      if selected_sort.keys.length > 0
        all_headers = headers.each do |header|
          if header[:field] == selected_sort['field']
            header[:sorted_by] = selected_sort['direction']
          else
            header[:sorted_by] = nil
          end.deep_dup
        end
      else
        all_headers = headers.deep_dup
      end
      return all_headers.select{ |header| !except.include?(header[:field]) }
    end

  end
end