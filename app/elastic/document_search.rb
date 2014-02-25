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
          title: { type: 'string' },
          description: { type: 'string' },
          category: { type: 'string' },
          created_on: { type: 'date' },
          route_key: { type: 'string', not_analyzed: true }
      }.merge(additional_index_mappings)
    end

  end
end
