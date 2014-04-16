module RedmineElasticsearch

  class IndexerError < StandardError
  end

  class IndexerService
    ROUTE_KEY = 'abc'

    class << self
      def recreate_index
        delete_index if index_exists?
        create_index
        update_mapping
      end

      def reindex_all(options = {}, &block)
        recreate_index
        for_each_parent_project do |parent_project|
          search_klasses.each do |search_klass|
            update_search_klass_for_project(search_klass, parent_project, options, &block)
          end
        end
      end

      def reindex(search_type, options = {}, &block)
        search_klass = find_search_klass(search_type)
        create_index unless index_exists?
        for_each_parent_project do |parent_project|
          update_search_klass_for_project(search_klass, parent_project, options, &block)
        end
      end

      def count_estimated_records(search_type = nil)
        search_klass = search_type && find_search_klass(search_type)
        search_klass ? search_klass.count : search_klasses.inject(0) { |sum, klass| sum + klass.count }
      end

      protected

      def for_each_parent_project(&block)
        ParentProject.searching_scope.find_each do |parent_project|
          parent_project.update_index
          block.call(parent_project)
        end
        ParentProject.index.refresh
      end

      def update_search_klass_for_project(search_klass, parent_project, options, &block)
        project_id = parent_project.id
        batch_size = options[:batch_size] || 300
        search_klass.searching_scope(project_id).find_in_batches(batch_size: batch_size) do |batch|
          search_klass.index.bulk :index, batch, parent: project_id, routing: ROUTE_KEY
          block.call(batch.length) if block_given?
        end
      end

      def update_mapping
        search_klasses.each { |search_klass| search_klass.update_mapping }
      end

      def index_exists?
        ParentProject.index.exists?
      end

      def create_index
        index = ParentProject.index
        result = index.create settings: ParentProject.index_settings, mappings: ParentProject.index_mappings
        raise IndexerError.new("Can't create index: \n#{index.response.try(:body)}\n") unless result
      end

      def delete_index
        ParentProject.index.delete
      end

      def search_klasses
        Redmine::Search.available_search_types.map { |type| type.to_s.classify.constantize }
      end

      def find_search_klass(search_type)
        validate_search_type(search_type)
        search_type.to_s.classify.constantize
      end

      def validate_search_type(search_type)
        unless Redmine::Search.available_search_types.include?(search_type)
          raise IndexError.new("Wrong search type [#{search_type}]. Available search types are #{Redmine::Search.available_search_types}")
        end
      end
    end
  end
end
