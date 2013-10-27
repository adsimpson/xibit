class Xibit::Serializer
  
  module Camelize

    extend ActiveSupport::Concern
   
    included do
      class_attribute :_camelize
    end
    
    # CLASS METHODS
    module ClassMethods
  
      # Sets camelization for attribute names
      #
      #   :lower = camelCaseLikeThis
      #   true   = CamelCaseLikeThis
      #   false  = dont_camel_case_anything
      #
      def camelize(camelize)
        self._camelize = camelize
      end
      # alias_method :camelize=, :camelize
      
      
      def camelize_value(value, camelize = nil)
        camelize = self._camelize if camelize.nil?
        return nil unless value
        if camelize.to_s == 'lower'
          value.to_s.camelize(:lower)
        elsif camelize
          value.to_s.camelize
        else
          value.to_s
        end.to_sym
      end
      
    end
    
    # INSTANCE METHODS
    
    def camelize_value(value, camelize = nil)
      self.class.camelize_value value, camelize
    end
    
        
  end
    
  
end