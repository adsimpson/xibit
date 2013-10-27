class Xibit::Serializer
  
  module Meta

    extend ActiveSupport::Concern
 
    # INSTANCE METHODS
    
private

   def rationalize_meta_options
     config = configuration_for :meta
     
     if config[:active] == false
       # no meta data returned if specified in serializer
       options[:meta] = false
     elsif options.has_key? :meta
       # defer to controller options if specified
     else
       # defer to request parameters if specified
       p = config.fetch :param, :meta
       options[:meta] = false if (params[p] == 'false')
     end
   end    
    
   def serialize_meta
      hash = {}
      return hash if options[:meta] == false
      meta_data = options[:meta] || {}
      
      if (resource_type == :collection)
        meta_data[:count] = object.count if (!meta_data.has_key?(:count) && object.respond_to?(:count))
        meta_data.merge! serialize_meta_pagination
      end
      
      unless meta_data.empty?
        meta_key = configuration_for(:meta).fetch :key, :meta
        hash.merge! meta_key ? {meta_key => meta_data} : meta_data
      end
      hash
    end
        
  end
    
  
end