class RedmineElasticsearch::SerializerService
  class << self

    def serialize_to_json(object)
      object_type = object.class.name.to_sym
      serializer_klass(object_type).new(object).to_json
    end

    private

    def serializer_klass(object_type)
      @serializers ||= {}
      @serializers[object_type] ||= build_serializer_klass(object_type)
    end

    def build_serializer_klass(object_type)
      parent = "#{object_type.to_s.classify}Serializer".safe_constantize || BaseSerializer
      serializer_klass = Class.new(parent)
      object_type_schema = SearchIndex.find_by_search_type(object_type)
      serializer_klass.apply_schema(object_type_schema) if object_type_schema
    end

  end
end
