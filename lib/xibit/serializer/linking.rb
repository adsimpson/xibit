class Xibit::Serializer
  
  module Linking

    extend ActiveSupport::Concern
   
    included do
      class_attribute :_link_configs
      self._link_configs = []
    end
    
    # CLASS METHODS
    module ClassMethods
  
      # Declares a hypermedia link in the document.
      # The block is executed in instance context, so you may call properties or other accessors.
      # Note that you're free to put decider logic into #link blocks, too.
      def link(options, &block)
        options = {:rel => options} unless options.is_a?(Hash)
        self._link_configs += [[options, block]]
      end
      
    end
    
    # INSTANCE METHODS
   
private
    
    def rationalize_linking_options
      config = configuration_for :links
      
      if config[:active] == false
        # no links returned if specified in serializer
        options[:links] = false
      elsif options.has_key? :links
        # defer to controller options if specified
      else
        # defer to request parameters if specified
        p = config.fetch :param, :links
        options[:links] = (params[p] == 'true') unless params[p].nil?
      end
    end
      
    # Returns a hash representation of the serializable
    # object links.
    def include_links!
      return if options[:links] == false
      key = configuration_for(:links).fetch :key, :_links
      prepare_links!
      @node.merge!(key => links) if links.any?
    end
    
    attr_writer :links
    
    def links
      @links ||= {}
    end
  
    # Setup hypermedia links by invoking their blocks
    def prepare_links!(*args)
      compile_links_for(_link_configs, *args).each do |link|  
        rel = link.delete :rel
        links[rel] = link
      end
    end  
    
    def compile_links_for(configs, *args)
      configs.collect do |config|
        options, block  = config.first, config.last
        href            = run_link_block(block, *args) or next
        
        prepare_link_for(href, options)
      end.compact 
    end
    
    def prepare_link_for(href, options)
      options.merge! href.is_a?(Hash) ? href : {:href => href}
      options.deep_dup
    end
    
    def run_link_block(block, *args)
      instance_exec(*args, &block)
    end
        
  end
    
  
end