module DocumentSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          document: {
              _parent: { type: 'parent_project' },
              _routing: { required: true, path: 'route_key' },
              properties: document_mappings_hash
          }
      }
    end

    def document_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },
          route_key: { type: 'string', not_analyzed: true },

          # acts_as_event fields
          created_on: { type: 'date', index_name: 'datetime' },
          title: { type: 'string', boost: 8 },
          description: { type: 'string', boost: 4 },
          author: { type: 'string' },
          url: { type: 'string', index: 'not_analyzed' },
          type: { type: 'string', index: 'not_analyzed' },

          category: { type: 'string' }
      }.merge(additional_index_mappings)
    end

    def allowed_to_search_query(user, options = {})
      options = options.merge(
          permission: :view_documents,
          type: 'document'
      )
      ParentProject.allowed_to_search_query(user, options)
    end
  end
end
