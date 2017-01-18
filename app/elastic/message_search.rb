module MessageSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def allowed_to_search_query(user, options = {})
      options = options.merge(
        permission: :view_messages,
        type:       'message'
      )
      ParentProject.allowed_to_search_query(user, options)
    end

  end
end
