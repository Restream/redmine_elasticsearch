module NewsSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          news: { properties: news_mappings_hash }
      }
    end

    def news_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },

          title: { type: 'string' },
          summary: { type: 'string' },
          description: { type: 'string' },
          author: { type: 'string' },

          created_on: { type: 'date' },
          comments_count: { type: 'integer', index: 'not_analyzed' }

      }.merge(additional_index_mappings)
    end

  end
end
