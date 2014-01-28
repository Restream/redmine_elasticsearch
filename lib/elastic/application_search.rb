module ApplicationSearch
  extend ActiveSupport::Concern
  included do
    include Tire::Model::Search

    prefix = "#{Rails.application.class.parent_name.downcase}_#{Rails.env}"
    Tire::Model::Search.index_prefix(prefix)

    after_commit :async_update_index
  end

  def async_update_index
    Workers::Indexer.defer(self)
  end

  module ClassMethods

    def recreate_index(klass = self, sync = true)
      klass.index.delete if klass.index.exists?
      klass.index.create settings: index_settings, mappings: index_mapping
      sync ? sync_update_index(klass) : async_update_index(klass)
    end

    def sync_update_index(klass)
      klass.find_each{ |instance| instance.update_index }
    end

    def async_update_index(klass)
      klass.find_each{ |instance| Workers::Indexer.defer(instance) }
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
