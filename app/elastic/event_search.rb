module EventSearch
  extend ActiveSupport::Concern
  included do
    include ApplicationSearch

    def to_indexed_json
      EventSerializer.new(self).to_json
    end

  end

  module ClassMethods

    def index_settings
      {}
    end

    def index_mapping
      event_type = self.class.name.underscore.to_sym
      {
          event_type => { properties: event_mapping_hash }
      }
    end

    def event_mapping_hash
      {
          id: { type: 'integer' },
          event_date: { type: 'date' },
          event_datetime: { type: 'date' },
          event_title: { type: 'string' },
          event_description: { type: 'string' },
          event_author: { type: 'string' },
          event_type: { type: 'string' }
      }
    end
  end
end
