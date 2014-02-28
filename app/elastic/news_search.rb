module NewsSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          news: {
              _parent: { type: 'parent_project' },
              _routing: { required: true, path: 'route_key' },
              properties: news_mappings_hash
          }
      }
    end

    def news_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },

          # acts_as_event fields
          created_on: { type: 'date', index_name: 'datetime' },
          title: { type: 'string' },
          description: { type: 'string' },
          author: { type: 'string' },
          url: { type: 'string' },
          type: { type: 'string', index: 'not_analyzed' },

          summary: { type: 'string' },
          created_on: { type: 'date' },
          comments_count: { type: 'integer', index: 'not_analyzed' },
          route_key: { type: 'string', not_analyzed: true }
      }.merge(additional_index_mappings)
    end

    def allowed_to_search_query(user, options = {})
      options = options.merge(
          permission: :view_news,
          type: 'news'
      )
      ParentProject.allowed_to_search_query(user, options)
    end
  end
end
