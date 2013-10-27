require 'xibit/serializer/root'
require 'xibit/serializer/meta'
require 'xibit/serializer/linking'
require 'xibit/serializer/camelize'
require 'xibit/serializer/attributes'
require 'xibit/serializer/sorting'
require 'xibit/serializer/paging'
require 'xibit/serializer/searching'
require 'xibit/serializer/url_methods'


module Xibit
  
  class Serializer
    
    class_attribute :_configuration
    self._configuration = {}
    
    include Xibit::Serializer::Root    
    include Xibit::Serializer::Meta    
    include Xibit::Serializer::Linking
    include Xibit::Serializer::Camelize
    include Xibit::Serializer::Attributes
    include Xibit::Serializer::Sorting
    include Xibit::Serializer::Paging
    include Xibit::Serializer::Searching
    include Xibit::Serializer::UrlMethods
    
    # CLASS METHODS
    
    def self.inherited(subclass)
      subclass._configuration = self._configuration.deep_dup
    end
   
    # Accepts a list of classes this serializer knows how to serialize.
    # @param [String, [String]] klasses Any number of names of classes this serializer serializes.
    def self.serializes(*klasses)
      Xibit.add_serializer_class(self, *klasses)
    end
    
    # The model class associated with this serializer.
    def self.model_class
      name.demodulize.sub(/Serializer$/, '').constantize
    end
      
    def self.configure(name, config=nil)
      hash = self._configuration[name] ||= {}
      unless config.nil?
        hash.merge! config.is_a?(Hash) ? config : {:active => config}
      end
      hash
    end
      
    def self.configuration_for(name)
      configure name 
    end
    
    # INSTANCE METHODS
    
    attr_accessor :object, :options, :scope, :params, :resource_type
    #attr_reader :root
    
    def initialize(object, options={})
      @options = options
      @scope = options[:scope]      
      @params = options[:params]
      params.symbolize_keys! if params.respond_to? :symbolize_keys!
      
      @resource_type = object.respond_to?(:to_ary) ? :collection : :instance
      @object = on_initialize(object)
    end

    def on_initialize(object)
      return object unless options.delete :is_root
     
      rationalize_root_options
      rationalize_meta_options 
      rationalize_linking_options
      rationalize_attribute_options
      
      if resource_type == :collection
        # Paging
        rationalize_paging_options
        object = object.paginate(:page => options[:page], :per_page => options[:page_size]) if options[:page_size]
        # Sorting
        rationalize_sorting_options 
        object = object.order(options[:sort]) if options[:sort]
        # Search
        rationalize_search_options
        object = object.where(options[:search]) if options[:search]
      end
      object
    end
  
    def configuration_for(name)
      self.class.configuration_for name 
    end
    
    # Returns a json representation of the serializable
    # object including the root.
    def as_json(args={})
      root = args.fetch(:root, options[:root])
      data = serialize root[:type]
      
      if root[:type] == :collection && !root[:key]
        data
      else
        hash = {}
        hash.merge! serialize_meta
        hash.merge! root[:key] ? {root[:key] => data} : data
      end
          
    end

    def serialize(root_type=nil)
      if resource_type == :collection
        serialize_collection
      elsif root_type == :collection
        serialize_collection [object]
      else
        serializable_hash
      end
    end

    def serialize_collection(collection=nil)
      collection ||= object
      collection.map do |instance|
        #serializer =  (instance.respond_to?(:xibit_serializer) && instance.send(:xibit_serializer)) ||
        #              self.class.name.to_sym
        
        serializer = self.class
        serializer.new(instance, options.merge(root: nil)).serializable_hash
      end
    end
      
    # Returns a hash representation of the serializable
    # object without the root.
    def serializable_hash
      return nil if @object.nil?
      @node = attributes
      include_links!
      # include_associations! if _embed
      @node
    end

    # Returns options[:scope]
    def scope
      @options[:scope]
    end
        
  end
  
end
