module ApplicationSearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    index_name RedmineElasticsearch::INDEX_NAME

    after_commit :async_update_index
  end

  def to_indexed_json
    RedmineElasticsearch::SerializerService.serialize_to_json(self)
  end

  def async_update_index
    Workers::Indexer.defer(self)
  end

  module ClassMethods

    def index_mapping
      {
        document_type => {
          _parent: { type: 'parent_project' }
        }
      }
    end

    def additional_index_mappings
      return {} unless Rails.configuration.respond_to?(:additional_index_properties)
      Rails.configuration.additional_index_properties[self.name.tableize.to_sym] || {}
    end

    # Update mapping for document type
    def update_mapping
      __elasticsearch__.client.indices.put_mapping(
        index: index_name,
        type:  document_type,
        body:  index_mapping
      )
    end

    def allowed_to_search_query(user, options = {})
      options = options.merge(
        permission: :view_project,
        type:       document_type
      )
      ParentProject.allowed_to_search_query(user, options)
    end

    def searching_scope(project_id)
      self.where('project_id = ?', project_id)
    end

    # Import all records to elastic
    # @return [Integer] errors count
    def import(options = {}, &block)
      # Batch size for bulk operations
      batch_size = options.fetch(:batch_size, RedmineElasticsearch::BATCH_SIZE_FOR_IMPORT)

      # Document type
      type       = options.fetch(:type, document_type)

      # Imported records counter
      imported   = 0

      # Errors counter
      errors     = 0

      find_in_batches(batch_size: batch_size) do |items|
        response = __elasticsearch__.client.bulk(
          index: index_name,
          type:  type,
          body:  items.map do |item|
            data   = item.to_indexed_json
            parent = data.delete :_parent
            { index: { _id: item.id, _parent: parent, data: data } }
          end
        )
        imported += items.length
        errors   += response['items'].map { |k, v| k.values.first['error'] }.compact.length

        # Call block with imported records count in batch
        yield(imported) if block_given?
      end
      errors
    end

    def remove_from_index(id)
      __elasticsearch__.client.delete index: index_name, type: document_type, id: id
    end
  end

  def update_index
    self.class.where(id: self.id).import
  end
end
