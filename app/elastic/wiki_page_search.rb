module WikiPageSearch
  extend ActiveSupport::Concern
  included do
    include ApplicationSearch

    def to_indexed_json
      WikiPageSerializer.new(self).to_json
    end

  end

  module ClassMethods

    def index_settings
      {}
    end

    def index_mapping
      {
          wiki_page: { properties: wiki_page_mapping_hash }
      }
    end

    def wiki_page_mapping_hash
      {
          id: { type: 'integer' },
          event_date: { type: 'date' },
          event_datetime: { type: 'date' },
          event_title: { type: 'string' },
          event_description: { type: 'string' },
          event_type: { type: 'string' }
      }
    end

  end
end
