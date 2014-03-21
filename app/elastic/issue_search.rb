module IssueSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          issue: {
              _parent: { type: 'parent_project' },
              _routing: { required: true, path: 'route_key' },
              properties: issue_mappings_hash
          }
      }
    end

    def issue_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },
          route_key: { type: 'string', not_analyzed: true },

          # acts_as_event fields
          created_on: { type: 'date', index_name: 'datetime' },
          subject: { type: 'string', index_name: 'title',
                     search_analyzer: 'search_analyzer',
                     index_analyzer: 'index_analyzer' },
          description: { type: 'string',
                         search_analyzer: 'search_analyzer',
                         index_analyzer: 'index_analyzer' },
          author: { type: 'string' },
          url: { type: 'string', index: 'not_analyzed' },
          type: { type: 'string', index: 'not_analyzed' },

          updated_on: { type: 'date' },
          closed_on: { type: 'date' },
          due_date: { type: 'date' },

          author_id: { type: 'integer', index: 'not_analyzed' },

          assigned_to: { type: 'string' },
          assigned_to_id: { type: 'integer', index: 'not_analyzed' },

          category: { type: 'string' },
          status: { type: 'string' },
          done_ratio: { type: 'integer' },

          custom_field_values: { type: 'string', index_name: 'cfv' },

          private: { type: 'boolean', index_name: 'is_private' },
          closed: { type: 'boolean', index_name: 'is_closed' },

          priority: { type: 'string' },
          fixed_version: { type: 'string', index_name: 'version' },

          journals: {
              properties: {
                  id: { type: 'integer', index: 'not_analyzed' },
                  notes: { type: 'string',
                           index_name: 'notes',
                           search_analyzer: 'search_analyzer',
                           index_analyzer: 'index_analyzer' }
              }
          }
      }.merge(additional_index_mappings)
    end

    def allowed_to_search_query(user, options = {})
      options = options.merge(
          permission: :view_issues,
          type: 'issue'
      )
      ParentProject.allowed_to_search_query(user, options) do |role, user|
        if user.logged?
          case role.issues_visibility
            when 'all'
              nil
            when 'default'
              user_ids = [user.id] + user.groups.map(&:id)
              {
                  bool: {
                      should: [
                          { term: { is_private: { value: false } } },
                          { term: { author_id: { value: user.id } } },
                          { terms: { assigned_to_id: user_ids } },
                      ],
                      minimum_should_match: 1
                  }
              }
            when 'own'
              user_ids = [user.id] + user.groups.map(&:id)
              {
                  bool: {
                      should: [
                          { term: { author_id: { value: user.id } } },
                          { terms: { assigned_to_id: user_ids } },
                      ],
                      minimum_should_match: 1
                  }
              }
            else
              { term: { id: { value: 0 } } }
          end
        else
          { term: { is_private: { value: false } } }
        end
      end
    end
  end
end
