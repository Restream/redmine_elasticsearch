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

    def index_document_type
      self.name.underscore
    end

    def index_mappings
      {
        document_type => {
          _parent:    { type: 'parent_project' },
          _routing:   { required: true, path: 'route_key' },
          properties: {
                        id:         { type: 'integer' },
                        project_id: { type: 'integer', index: 'not_analyzed' },
                        route_key:  { type: 'string', not_analyzed: true },
                      }.merge(additional_index_mappings)
        }
      }
    end

    def attachments_mappings
      {
        attachments: {
          properties: {
            created_on:  { type: 'date', index_name: 'datetime' },
            filename:    { type:            'string', index_name: 'title',
                           search_analyzer: 'search_analyzer',
                           index_analyzer:  'index_analyzer' },
            description: { type:            'string',
                           search_analyzer: 'search_analyzer',
                           index_analyzer:  'index_analyzer' },
            author:      { type: 'string' },

            filesize:    { type: 'integer', index: 'not_analyzed' },
            digest:      { type: 'string', index: 'not_analyzed' },
            downloads:   { type: 'integer', index: 'not_analyzed' },
            author_id:   { type: 'integer', index: 'not_analyzed' },

            file:        {
              type:   'attachment',
              fields: {
                file:           { store:           'no',
                                  search_analyzer: 'search_analyzer',
                                  index_analyzer:  'index_analyzer' },
                title:          { store:           'no',
                                  search_analyzer: 'search_analyzer',
                                  index_analyzer:  'index_analyzer' },
                date:           { store: 'no' },
                author:         { store: 'no' },
                keywords:       { search_analyzer: 'search_analyzer',
                                  index_analyzer:  'index_analyzer' },
                content_type:   { store: 'no' },
                content_length: { store: 'no' },
                language:       { store: 'no' }
              }
            }
          }
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
        type:       document_type
      )
      ParentProject.allowed_to_search_query(user, options)
    end

    def searching_scope(project_id)
      self.where('project_id = ?', project_id)
    end
  end

end
