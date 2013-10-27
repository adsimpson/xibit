class Xibit::Serializer
  
  module Root

    extend ActiveSupport::Concern
   
    # INSTANCE METHODS
  
    def rationalize_root_options(res_type=nil)
      res_type ||= resource_type
      config = configuration_for :root
      res_type_root = config.fetch(res_type, options.fetch(:root, true))
      
      if (config[:active] == false || res_type_root == false)
        # no root if specified in serializer
        options[:root] = {:key => false, :type => res_type}
      else
        class_name = self.class.name.demodulize.underscore.sub(/_serializer$/, '').to_sym unless self.class.name.blank?
        key = if res_type_root == true
          res_type == :collection ? class_name.to_s.pluralize : class_name
        else
          res_type_root || class_name
        end
        
        # if the :instance config re-directs to the :collection config => use the :collection config
        if (res_type == :instance && key == :collection)
          rationalize_root_options key 
        else
          options[:root] = {:key => camelize_value(key), :type => res_type}
        end
      end
    end
    
  end
   
  
end