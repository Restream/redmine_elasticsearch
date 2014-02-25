module WikiPageSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          wiki_page: {
              _parent: { type: 'parent_project' },
              _routing: { required: true, path: 'route_key' },
              properties: wiki_page_mappings_hash
          }
      }
    end

    def wiki_page_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },

          title: { type: 'string' },
          text: { type: 'string' },

          created_on: { type: 'date' },
          updated_on: { type: 'date' },

          route_key: { type: 'string', not_analyzed: true }

      }.merge(additional_index_mappings)
    end

    def searching_scope(project_id)
      self.where('project_id = ?', project_id).joins(:wiki)
    end
  end
end
