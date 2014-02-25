module MessageSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          message: {
              _parent: { type: 'parent_project' },
              _routing: { required: true, path: 'route_key' },
              properties: message_mappings_hash
          }
      }
    end

    def message_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },

          subject: { type: 'string' },
          content: { type: 'string' },
          author: { type: 'string' },

          created_on: { type: 'date' },
          updated_on: { type: 'date' },
          replies_count: { type: 'date', index: 'not_analyzed' },
          route_key: { type: 'string', not_analyzed: true }

      }.merge(additional_index_mappings)
    end

    def searching_scope(project_id)
      self.where('project_id = ?', project_id).joins(:board)
    end
  end
end
