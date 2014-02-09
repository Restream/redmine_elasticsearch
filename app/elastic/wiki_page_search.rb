module WikiPageSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          wiki_page: { properties: wiki_page_mappings_hash }
      }
    end

    def wiki_page_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },

          title: { type: 'string' },
          text: { type: 'string' },

          created_on: { type: 'date' },
          updated_on: { type: 'date' }

      }.merge(additional_index_mappings)
    end

  end
end
