module Xibit
  
  class SerializerCollection
    
    # @return [Hash] The serializers this collection knows about, keyed on the names of the classes that can be serialized.
    def serializers
      @serializers ||= {}
    end

    # @param [String, Class] serializer_class The serializer class that knows how to serialize all of the classes given in +klasses+.
    # @param [*Class] klasses One or more classes that can be serialized by +serializer_class+.
    def add_serializer_class(serializer_class, *klasses)
      klasses.each do |klass|
        serializers[klass.to_s] = serializer_class
      end
    end

    # @return [Xibit::Serializer, nil] The serializer that knows how to serialize the class +klass+, or +nil+ if there isn't one.
    def serializer_class_for(klass)
      serializers[klass.to_s]
    end

    # @return [Xibit::Serializer] The serializer that knows how to serialize the class +klass+.
    # @raise [ArgumentError] if there is no known serializer for +klass+.
    def serializer_class_for!(klass)
      self.serializer_class_for(klass) || raise(ArgumentError, "Unable to find a serializer for class #{klass}")
    end
      
  end
  
end

