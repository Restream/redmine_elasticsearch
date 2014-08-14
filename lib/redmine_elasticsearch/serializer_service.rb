class RedmineElasticsearch::SerializerService
  class << self

    def serialize_to_json(object)
      serializer(object).to_json
    end

    def serializer(object)
      object_type = object.class.name.tableize.to_sym
      serializer_klass(object_type).new(object)
    end

    private

    def serializer_klass(object_type)
      @serializers ||= {}
      @serializers[object_type] ||= build_serializer_klass(object_type)
    end

    def build_serializer_klass(object_type)
      parent = "#{RedmineElasticsearch.type2class_name(object_type)}Serializer".safe_constantize || BaseSerializer
      serializer_klass = Class.new(parent)
      additional_props = additional_index_properties(object_type)
      add_additional_properties(serializer_klass, additional_props) if additional_props
      serializer_klass
    end

    def additional_index_properties(object_type)
      return nil unless Rails.configuration.respond_to?(:additional_index_properties)
      Rails.configuration.additional_index_properties[object_type]
    end

    def add_additional_properties(serializer_klass, additional_props)
      additional_props.each do |key, value|
        nested_props = value[:properties]
        if nested_props.nil?
          add_attribute_to_serializer(serializer_klass, key)
        else
          add_association_to_serializer(serializer_klass, key, nested_props)
        end
      end
    end

    def add_attribute_to_serializer(serializer_klass, name)
      serializer_klass.send :attribute, name
    end

    def add_association_to_serializer(serializer_klass, name, options)
      nested_serializer_klass = Class.new(BaseSerializer)
      add_additional_properties(nested_serializer_klass, options)
      serializer_klass.send :has_many, name, :serializer => nested_serializer_klass
    end

  end
end
