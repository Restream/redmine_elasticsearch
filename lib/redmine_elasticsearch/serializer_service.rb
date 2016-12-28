class RedmineElasticsearch::SerializerService
  class << self

    # Serialize instance of searchable klass as json
    # @param [Object] object instance of searchable klass
    # @param [Class] serializer_klass class that will be used to construct serializer
    #
    def serialize_to_json(object, serializer_klass = nil)
      serializer(object, serializer_klass).as_json
    end

    # Get serializer for specific object
    # @param [Object] object instance of searchable klass
    # @param [Class] serializer_klass class that will be used to construct serializer
    #
    def serializer(object, serializer_klass = nil)
      object_type = object.class.name.tableize.to_sym
      get_serializer_klass(object_type, serializer_klass).new(object)
    end

    private

    # Get serializer for specific document type
    # @param [String] object_type document type
    # @param [Class] serializer_klass class that will be used to construct serializer
    #
    def get_serializer_klass(object_type, serializer_klass = nil)
      @serializers              ||= {}
      @serializers[object_type] ||= build_serializer_klass(object_type, serializer_klass)
    end

    # Build serializer. Construct new class and add properties from additional config
    # @param [String] object_type document type
    # @param [Class] serializer_klass class that will be used to construct serializer
    #
    def build_serializer_klass(object_type, serializer_klass = nil)
      parent           = serializer_klass ||
        "#{RedmineElasticsearch.type2class_name(object_type)}Serializer".safe_constantize ||
        BaseSerializer
      serializer_klass = Class.new(parent)
      additional_props = additional_index_properties(object_type)
      add_additional_properties(serializer_klass, additional_props) if additional_props
      serializer_klass
    end

    # Get additional options that should be added to indexed json by serializer
    # @param [String] object_type document type
    #
    #
    # Example of additional properties in config/additional_environment.rb:
    #
    # config.additional_index_properties = {
    #   issues: {
    #     tags: { type: 'string' }
    #   }
    # }
    #
    def additional_index_properties(object_type)
      return nil unless Rails.configuration.respond_to?(:additional_index_properties)
      Rails.configuration.additional_index_properties[object_type]
    end

    # Add additional properties to serializer
    # @param [Class] serializer_klass serailizer class to extend
    # @param [Hash] additional_props properties which extends serializer
    #
    def add_additional_properties(serializer_klass, additional_props)
      additional_props.each do |key, value|
        props = value[:properties]
        if props.nil?
          add_attribute_to_serializer(serializer_klass, key)
        else
          add_association_to_serializer(serializer_klass, key, props)
        end
      end
    end

    # Add attribute to serializer
    # @param [Class] serializer_klass serailizer class to extend
    # @param [String] name attribute name
    #
    def add_attribute_to_serializer(serializer_klass, name)
      serializer_klass.send :attribute, name
    end

    # Add association to serializer
    # @param [Class] serializer_klass serailizer class to extend
    # @param [String] name association name
    # @param [Hash] options additional attributes for associations
    #
    def add_association_to_serializer(serializer_klass, name, options)
      props_serializer_klass = Class.new(BaseSerializer)
      add_additional_properties(props_serializer_klass, options)
      serializer_klass.send :has_many, name, serializer: props_serializer_klass
    end

  end
end
