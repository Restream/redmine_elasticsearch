module IssueSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def searching_scope
      self.scoped.includes(
          [:status, :project, :tracker, :author, :assigned_to, :category, :status]
      )
    end

    def index_mappings
      {
          issue: { properties: issue_mappings_hash }
      }
    end

    def issue_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },

          subject: { type: 'string' },
          description: { type: 'string' },

          created_on: { type: 'date' },
          updated_on: { type: 'date' },
          closed_on: { type: 'date' },

          author: { type: 'string' },
          author_id: { type: 'integer', index: 'not_analyzed' },

          assigned_to: { type: 'string' },
          assigned_to_id: { type: 'integer', index: 'not_analyzed' },

          category: { type: 'string' },
          status: { type: 'string' },
          done_ratio: { type: 'integer' },

          custom_field_values: { type: 'string', index_name: 'cfv' },

          is_private: { type: 'boolean' },

          journals: {
              properties: {
                  id: { type: 'integer', index: 'not_analyzed' },
                  notes: { type: 'string' }
              }
          }
      }.merge(additional_index_mappings)
    end

    def allowed_to_search_query(user, options = {})
      options[:permission] = :view_issues
      Project.allowed_to_search_query(user, options) do |role, user|
        if user.logged?
          case role.issues_visibility
            when 'all'
              nil
            when 'default'
              user_ids = [user.id] + user.groups.map(&:id)
              "(is_private:false OR author_id:#{user.id} OR assigned_to_id:(#{user_ids.join(' ')}))"
            when 'own'
              user_ids = [user.id] + user.groups.map(&:id)
              "(author_id:#{user.id} OR assigned_to_id:(#{user_ids.join(' ')}))"
            else
              'id:0'
          end
        else
          'is_private:false'
        end
      end
    end
  end
end
