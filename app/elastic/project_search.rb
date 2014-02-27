module ProjectSearch
  extend ActiveSupport::Concern

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
          name: { type: 'string', analyzer: 'index_analyzer' },
          description: { type: 'string', analyzer: 'index_analyzer' },
          homepage: { type: 'string' },
          identifier: { type: 'string' },
          created_on: { type: 'date' },
          updated_on: { type: 'date' },
          custom_field_values: { type: 'string', index_name: 'cfv' },
          is_public: { type: 'boolean' },
          route_key: { type: 'string', not_analyzed: true }
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
      self.where("#{Project.table_name}.id = ?", project_id).includes(searchable_options[:include])
    end
  end
end
