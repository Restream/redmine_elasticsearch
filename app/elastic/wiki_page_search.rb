module WikiPageSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def allowed_to_search_query(user, options = {})
      options = options.merge(
        permission: :view_wiki_pages,
        type:       'wiki_page'
      )
      ParentProject.allowed_to_search_query(user, options)
    end

  end
end
