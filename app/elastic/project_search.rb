module ProjectSearch
  extend ActiveSupport::Concern

  def async_update_index
    Workers::Indexer.defer(ParentProject.find(id))
    Workers::Indexer.defer(self)
  end

  module ClassMethods

    def allowed_to_search_query(user, options = {})
      options = options.merge(
        permission: :view_project,
        type:       'project'
      )
      ParentProject.allowed_to_search_query(user, options)
    end

  end
end
