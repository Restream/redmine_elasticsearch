# Patch for customize Elasticsearch::Model::Response::Results
module RedmineElasticsearch
  module Patches
    module ResponseResultsPatch

      # Returns the customized {Results} collection
      def results
        response.response['hits']['hits'].map { |hit| ::RedmineElasticsearch::SearchResult.new(hit) }
      end

    end
  end
end