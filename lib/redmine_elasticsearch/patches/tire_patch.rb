module RedmineElasticsearch::Patches::TirePatch
  extend ActiveSupport::Concern

  included do
    alias_method_chain :__get_results_with_load, :check
    alias_method_chain :__find_records_by_ids, :check
  end

  def __get_results_with_load_with_check(hits)
    return [] if hits.empty?

    records = {}
    @response['hits']['hits'].group_by { |item| item['_type'] }.each do |type, items|
      raise NoMethodError, "You have tried to eager load the model instances, " +
          "but Tire cannot find the model class because " +
          "document has no _type property." unless type

      begin
        klass = type.camelize.constantize
      rescue NameError => e
        raise NameError, "You have tried to eager load the model instances, but " +
            "Tire cannot find the model class '#{type.camelize}' " +
            "based on _type '#{type}'.", e.backtrace
      end

      records[type] = Array(__find_records_by_ids klass, items.map { |h| h['_id'] })
    end

    # Reorder records to preserve the order from search results
    @response['hits']['hits'].map do |item|
      records[item['_type']].detect do |record|
        record.id.to_s == item['_id'].to_s
      end || dummy_document(item)
    end
  end

  def __find_records_by_ids_with_check(klass, ids)
    @options[:load] === true ? klass.where(id: ids) : klass.find(ids, @options[:load])
  end

  def dummy_document(hit)
    document = {}

    # Update the document with fields and/or source
    document.update hit['_source'] if hit['_source']
    document.update __parse_fields__(hit['fields']) if hit['fields']

    # Set document ID
    document['id'] = hit['_id']

    # Update the document with meta information
    ['_score', '_type', '_index', '_version', 'sort', 'highlight', '_explanation'].each do |key|
      document.update key => hit[key]
    end

    # Return an instance of the "wrapper" class
    @wrapper.new(document)
  end
end

unless Tire::Results::Collection.included_modules.include?(RedmineElasticsearch::Patches::TirePatch)
  Tire::Results::Collection.send :include, RedmineElasticsearch::Patches::TirePatch
end
