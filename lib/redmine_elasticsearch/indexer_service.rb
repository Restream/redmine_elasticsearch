module RedmineElasticsearch

  class IndexerError < StandardError
  end

  class IndexerService
    class << self
      def reindex_all(&block)
        recreate_index
        update_mapping(&block)
        update_index
      end

      protected

      def update_index(&block)
        ParentProject.searching_scope.find_each do |parent_project|
          parent_project.update_index
          project_id = parent_project.id
          yield project_id if block_given?
          search_klasses.each do |search_klass|
            search_klass.searching_scope(project_id).find_in_batches do |batch|
              search_klass.index.bulk :index, batch, parent: project_id, routing: 'abc'
            end
          end
        end
        ParentProject.index.refresh
      end

      def update_mapping
        search_klasses.each { |search_klass| search_klass.update_mapping }
      end

      def recreate_index
        index = ParentProject.index
        index.refresh
        index.delete if index.exists?
        result = index.create settings: ParentProject.index_settings, mappings: ParentProject.index_mappings
        raise IndexerError.new("Can't create index: \n#{index.response.try(:body)}\n") unless result
      end

      def search_klasses
        Redmine::Search.available_search_types.map { |type| type.to_s.classify.constantize }
      end
    end
  end
end
