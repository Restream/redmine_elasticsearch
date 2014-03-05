module ProjectSearch
  extend ActiveSupport::Concern

  def async_update_index
    Workers::Indexer.defer(ParentProject.find(id))
    Workers::Indexer.defer(self)
  end

  module ClassMethods

    def index_mappings
      {
          project: {
              _parent: { type: 'parent_project' },
              _routing: { required: true, path: 'route_key' },
              properties: project_mappings_hash
          }
      }
    end

    def project_mappings_hash
      {
          id: { type: 'integer', index_name: 'project_id', not_analyzed: true },
          route_key: { type: 'string', not_analyzed: true },

          # acts_as_event fields
          created_on: { type: 'date', index_name: 'datetime' },
          name: { type: 'string', index_name: 'title', boost: 8 },
          description: { type: 'string', boost: 4 },
          author: { type: 'string' },
          url: { type: 'string', index: 'not_analyzed' },
          type: { type: 'string', index: 'not_analyzed' },

          homepage: { type: 'string' },
          identifier: { type: 'string' },
          updated_on: { type: 'date' },
          custom_field_values: { type: 'string', index_name: 'cfv' },
          is_public: { type: 'boolean' }
      }.merge(additional_index_mappings)
    end

    def allowed_to_search_query(user, options = {})
      options = options.merge(
          permission: :view_project,
          type: 'project'
      )
      ParentProject.allowed_to_search_query(user, options)
    end

    def searching_scope(project_id)
      self.where("#{Project.table_name}.id = ?", project_id)
    end
  end
end
