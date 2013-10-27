class Xibit::Serializer
  
  module Attributes

    extend ActiveSupport::Concern
   
    included do
      class_attribute :_attributes
      self._attributes = []
    end
    
    # CLASS METHODS
    module ClassMethods
      
      def attributes(*attrs)
        self._attributes += attrs

        attrs.each do |attr|
          unless method_defined?(attr)
            define_method attr do
              object.read_attribute_for_serialization(attr)
            end
          end
        end
      end

    end
    
    # INSTANCE METHODS

private
    
    def rationalize_attribute_options
      config = configuration_for :partials
      
      p = config.fetch :param, :fields
      attributes = params[p].to_s
      return if (options.has_key?(:attributes) || 
        options.has_key?(:exclude_attributes) || 
        config[:active] == false ||
        attributes.blank?)
      
      symbol = :attributes
      if attributes.chars.first == '-'
        attributes.slice!(0)
        symbol = :exclude_attributes
      end
      
      options[symbol] = attributes.split(',').map { |attribute| attribute.to_s.underscore.to_sym }
    end
    
    # Returns a hash representation of the serializable
    # object attributes.
    def attributes
      attrs = filter_partials(self.class._attributes.dup)
      filter(attrs).each_with_object({}) do |attr, hash|
        hash[camelize_value(attr)] = send(attr)
      end
    end
    
    def filter_partials(attrs)
      if options.has_key? :exclude_attributes
        attrs - Array(options[:exclude_attributes])
      elsif options.has_key? :attributes
        attrs.select! { |attr| Array(options[:attributes]).include? attr } 
      else
        attrs
      end
    end
        
    def filter(keys)
      keys
    end
      
  end
 
  
end