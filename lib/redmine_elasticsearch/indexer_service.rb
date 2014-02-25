class RedmineElasticsearch::IndexerService
  class << self
    def reindex_all
      ParentProject.recreate_index
      klasses = search_klasses
      klasses.each { |search_klass| search_klass.update_mapping }
      ParentProject.searching_scope.find_each do |parent_project|
        parent_project.update_index
        project_id = parent_project.id
        yield project_id if block_given?
        klasses.each do |search_klass|
          search_klass.searching_scope(project_id).find_in_batches do |batch|
            search_klass.index.bulk :index, batch, parent: project_id, routing: 'abc'
          end
        end
      end
    end

    def search_klasses
      Redmine::Search.available_search_types.map { |type| type.to_s.classify.constantize }
    end
  end
end
