module IssueSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def allowed_to_search_query(user, options = {})
      options = options.merge(
        permission: :view_issues,
        type:       'issue'
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
                  should:               [
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
                  should:               [
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
