class Xibit::Serializer
  
  module Paging

    extend ActiveSupport::Concern
   
    # CLASS METHODS
    
    module ClassMethods
     
      def default_page_size(size)
        configure :paging, {:default_page_size => size}
      end
      
    end
    
    # INSTANCE METHODS

    def rationalize_paging_options
      config = configuration_for :paging
      
      if config[:active] == false
        # no paging if specified in serializer
        options[:page_size] = false
      elsif options.has_key? :page_size
        # defer to controller options if specified
      else
        # defer to request parameters if specified
        page_size = params.fetch(config.fetch(:page_size_param, :page_size), config.fetch(:default_page_size, 10))
        options[:page_size] = (page_size.try(:to_i) || 0) unless page_size.nil?
      end
      
      options[:page] ||= params.fetch(config.fetch(:param, :page), 1).to_i
    end
    
    def serialize_meta_pagination
      hash = {}
      return hash unless object.respond_to? :total_entries
      
      hash[:pagination] =   {
        camelize_value(:page)          => object.current_page.try(:to_i),
        camelize_value(:page_size)     => object.per_page.try(:to_i),
        camelize_value(:page_count)    => object.total_pages.try(:to_i),
        camelize_value(:total_count)   => object.total_entries.try(:to_i)
        # :previous => resource.previous_page.try(:to_i),
        # :next     => resource.next_page.try(:to_i)
        }
      hash
    end
      

    
  end
  
end