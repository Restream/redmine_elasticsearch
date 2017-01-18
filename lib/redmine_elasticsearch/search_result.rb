module RedmineElasticsearch
  class SearchResult < Elasticsearch::Model::Response::Result

    def project
      @project ||= Project.find_by_id(project_id)
    end

    # Adding event attributes aliases
    %w(datetime title description author type url).each do |attr|
      src = <<-END_SRC
            def event_#{attr}(*args)   
              #{attr}
            end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end

  end
end