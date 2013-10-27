class Xibit::Serializer
  
  module Sorting

    extend ActiveSupport::Concern
   
    # CLASS METHODS
    
    module ClassMethods
      
      def default_sort_order(sort_string)
        sort = parse_sort_string sort_string 
        configure :sorting, {:default_sort_order => "#{sort[:attribute]} #{sort[:direction]}"}
      end
      
      def sort_attributes(*attrs)
        attrs.map! { |attr| attr.to_sym }
        configure :sorting, {:attributes => attrs}
      end
      
      def parse_sort_string(sort_string)
        sort = sort_string.to_s.split(' ')
        attribute = sort[0].to_s
        direction = sort[1].to_s.downcase
        if attribute.chars.first == '-'
          attribute.slice!(0)
          direction = 'desc' if direction.blank?
        end
        direction = 'asc' unless %w(asc desc).include? direction
        {:attribute => attribute.underscore, :direction => direction}
      end
      
    end
   
    # INSTANCE METHODS

private

    def parse_sort_string(sort_string)
      self.class.parse_sort_string sort_string 
    end
      
    def rationalize_sorting_options
      config = configuration_for :sorting
      sort_options = config[:attributes] || []
      
      if config[:active] == false
        # no paging if specified in serializer
        options[:sort] = false
      elsif options.has_key? :sort
        # defer to controller options if specified
      else
        # defer to request parameters if specified
        p = config.fetch :param, :order_by
        sort_by = params[p].to_s.split(',').map do |sort_string|
          sort = parse_sort_string sort_string 
          if sort_options.include? sort[:attribute].to_sym 
            "#{sort[:attribute]} #{sort[:direction]}"
          else
            nil
          end
        end.compact.join(',')
        # else use default sort order - if specified
        sort_by = config[:default_sort_order] if sort_by.blank?
        options[:sort] = sort_by unless sort_by.blank?
      end
    end
    
  end
  
end