module NewsSearch
  extend ActiveSupport::Concern
  included do
    include ApplicationSearch

    def to_indexed_json
      NewsSerializer.new(self).to_json
    end

  end

  module ClassMethods

    def elastic(options = {})
      query_options = {}
      Tire.search(News.index_name, query_options) do
        query do
          string options[:q]
        end
      end
    end

    def index_settings
      {}
    end

    def index_mapping
      {
          news: { properties: news_mapping_hash }
      }
    end

    def news_mapping_hash
      event_mapping_hash
    end

  end
end
