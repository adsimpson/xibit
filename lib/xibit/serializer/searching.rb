require 'xibit/query_builder'

class Xibit::Serializer
  
  module Searching

    extend ActiveSupport::Concern
   
    # CLASS METHODS
    
    module ClassMethods
      
      def search_attributes(*attrs)
        hash = attrs.each_with_object({}) do |attr, hash|
          if attr.is_a?(Hash)
            hash.merge! attr
          else
            hash[attr] = nil
          end
        end
        configure :search, {:attributes => hash}
      end
   
      def query_attributes(*attrs)
        attrs.map! { |attr| attr.to_sym }
        configure :search, {:query_attributes => attrs}
      end
      
    end
          
    # INSTANCE METHODS

private
          
    def rationalize_search_options
      config = configuration_for :search
      
      if config[:active] == false
        # no searching if specified in serializer
        options[:search] = false
      else
        # defer to request parameters if specified
        p = config.fetch :query_param, :q
        query_attrs = config[:query_attributes] || []     
        attrs = config[:attributes] || {}
        
        options[:search] = if (p && params.has_key?(p) && !query_attrs.empty?)
            Xibit::QueryBuilder.new(options[:resource_class], [params[p]]).query_search(query_attrs)
          elsif !attrs.empty?
            Xibit::QueryBuilder.new(options[:resource_class], params).attribute_search(attrs)
          else
            false
          end
      end
    end

  end
   
end