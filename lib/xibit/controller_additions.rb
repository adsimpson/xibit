module Xibit
  
  module ControllerAdditions
      
    extend ActiveSupport::Concern
    
    included do
      class_attribute :_serialization_scope
      self._serialization_scope = :current_user
    end
    
    module ClassMethods
      def serialization_scope(scope)
        self._serialization_scope = scope
      end
    end
    
    def _render_option_json(resource, options)
      json = Xibit.serialize(resource, build_json_serializer_options(resource, options))
      
      if json
        super(json, options)
      else
        super
      end
    end 

private
    
    def default_serializer_options
      {}
    end
    
    def serialization_scope
      _serialization_scope = self.class._serialization_scope
      send(_serialization_scope) if _serialization_scope && respond_to?(_serialization_scope, true)
    end
    
    def build_json_serializer_options(resource, options)
      options = default_serializer_options.merge(options || {})
      options.merge!(:params => params)

      options[:is_root] = true
      
      options[:scope] = serialization_scope unless options.has_key? :scope 
      
      options[:resource_class] = 
        resource.respond_to?(:model) ? resource.model.name.constantize :
        resource.respond_to?(:to_ary) ? self.controller_name.classify.constantize : 
        resource.class.name.constantize
      
      options[:controller_class] = self.class.name
      options
    end
    
  end
    
end
