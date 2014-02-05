require 'will_paginate'
require 'will_paginate/active_record'

require 'xibit/version'
require 'xibit/railtie'
require 'xibit/serializer'
require 'xibit/serializer_collection'

module Xibit
  
  # Sets {default_namespace} to a new value.
  # @param [String] namespace
  # @return [String] the new default namespace
  def self.default_namespace=(namespace)
    @default_namespace = namespace
  end

  # The namespace that will be used by {serializer_collection} and {add_serializer_class} if none is given or implied.
  # @return [String] the default namespace
  def self.default_namespace
    @default_namespace || "none"
  end  

  # @param [String] namespace
  # @return [SerializerCollection] the {SerializerCollection} for the given namespace.
  def self.serializer_collection(namespace = nil)
    namespace ||= default_namespace
    @serializer_collection ||= {}
    @serializer_collection[namespace.to_s.downcase] ||= SerializerCollection.new
  end

  # Helper method to quickly add serializer classes that are in a namespace. For example, +add_serializer_class(Api::V1::UserSerializer, "User")+ would add +UserSerializer+ to the SerializerCollection for the +:v1+ namespace as the serializer for the +User+ class.
  # @param [Xibit::Serializer] serializer_class The serializer class that is being registered.
  # @param [Array<String, Class>] klasses Classes that will be serialized by the given serializer.
  def self.add_serializer_class(serializer_class, *klasses)
    serializer_collection(namespace_of(serializer_class)).add_serializer_class(serializer_class, *klasses)
  end

  # @param [Class] klass The Ruby class whose namespace we would like to know.
  # @return [String] The name of the module containing the passed-in class.
  def self.namespace_of(klass)
    names = klass.to_s.split("::")
    names[-2] ? names[-2] : default_namespace
  end
  
  # Used internally to create a new serializer object based on controller
  # settings and options for a given resource. These settings are typically
  # set during the request lifecycle or by the controller class, and should
  # not be manually defined for this method.
  def self.serialize(resource, options={})
    serializer = if options.has_key? :serializer
      options.delete :serializer
    else 
      options[:namespace] ||= namespace_of options[:controller_class]
      serializer_collection(options[:namespace]).serializer_class_for options[:resource_class]
    end
  
    return serializer ? serializer.new(resource, options) : nil
  end
  
end

begin
  require 'xibit/controller_additions'
  
  ActiveSupport.on_load :action_controller  do
    include Xibit::ControllerAdditions
  end
  
end