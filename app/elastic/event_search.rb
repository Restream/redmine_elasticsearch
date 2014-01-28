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
  end
end
