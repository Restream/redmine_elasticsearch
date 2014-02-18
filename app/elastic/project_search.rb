module ProjectSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          project: { properties: project_mappings_hash }
      }
    end

    def project_mappings_hash
      {
          id: { type: 'integer' },

          name: { type: 'string' },
          description: { type: 'string' },
          homepage: { type: 'string' },
          identifier: { type: 'string' },

          created_on: { type: 'date' },
          updated_on: { type: 'date' },

          is_public: { type: 'boolean' },

          custom_field_values: { type: 'string', index_name: 'cfv' }

      }.merge(additional_index_mappings)
    end

    def searching_scope
      self.active
    end

    def ids_with_enabled_module(module_name)
      EnabledModule.
          joins(:project).
          where("#{EnabledModule.table_name}.name = ?", module_name).
          pluck(:project_id)
    end

    def ids_not_archived
      Project.where('status <> ?', Project::STATUS_ARCHIVED).pluck(:id)
    end

    def allowed_to_search_query(user, permission, options={})

      perm = Redmine::AccessControl.permission(permission)

      project_ids = ids_not_archived

      # If the permission belongs to a project module, make sure the module is enabled
      project_ids &= ids_with_enabled_module(perm.project_module) if perm && perm.project_module

      project_ids &= options[:project_ids] if options[:project_ids]

      base_statement = "project_id:(#{project_ids.join(' ')})"

      if user.admin?
        base_statement
      else
        statement_by_role = {}
        role = user.logged? ? Role.non_member : Role.anonymous
        if role.allowed_to?(permission)
          public_ids = Project.all_public.map(&:id)
          statement_by_role[role] = "project_id:(#{public_ids.join(' ')})"
        end
        if user.logged?
          user.projects_by_role.each do |role, projects|
            if role.allowed_to?(permission) && projects.any?
              statement_by_role[role] = "project_id:(#{projects.collect(&:id).join(' ')})"
            end
          end
        end
        if statement_by_role.empty?
          'project_id:0'
        else
          if block_given?
            statement_by_role.each do |role, statement|
              if s = yield(role, user)
                statement_by_role[role] = "(#{statement} AND #{s})"
              end
            end
          end
          "#{base_statement} AND (#{statement_by_role.values.join(' OR ')})"
        end
      end
    end
  end
end
