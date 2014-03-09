module ApplicationSearch
  extend ActiveSupport::Concern

  included do
    include Tire::Model::Search

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

    def index_mappings
      {
          document_type => {
              _parent: { type: 'parent_project' },
              _routing: { required: true, path: 'route_key' },
              properties: {
                  id: { type: 'integer' },
                  project_id: { type: 'integer', index: 'not_analyzed' },
                  route_key: { type: 'string', not_analyzed: true },
              }.merge(additional_index_mappings)
          }
      }
    end

    def additional_index_mappings
      return {} unless Rails.configuration.respond_to?(:additional_index_properties)
      Rails.configuration.additional_index_properties[self.name.tableize.to_sym] || {}
    end

    def update_mapping
      index.refresh
      index_mappings.each do |k, v|
        index.mapping! k, v
      end
    end

    def allowed_to_search_query(user, options = {})
      options = options.merge(
          permission: :view_project,
          type: document_type
      )
      ParentProject.allowed_to_search_query(user, options)
    end

    def searching_scope(project_id)
      self.where('project_id = ?', project_id)
    end
  end

end
