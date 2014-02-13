module ApplicationSearch
  extend ActiveSupport::Concern

  included do
    include Tire::Model::Search

    prefix = "#{Rails.application.class.parent_name.downcase}_#{Rails.env}"
    Tire::Model::Search.index_prefix(prefix)

    after_commit :async_update_index
  end

  def to_indexed_json
    RedmineElasticsearch::SerializerService.serialize_to_json(self)
  end

  def async_update_index
    Workers::Indexer.defer(self)
  end

  module ClassMethods

    def recreate_index(sync = true)
      tire.index.delete if tire.index.exists?
      tire.index.create settings: index_settings, mappings: index_mappings
      sync ? update_index : async_update_index
    end

    def index_settings
      {
          analysis: {
              :analyzer => {
                  :index_analyzer => {
                      type: 'custom',
                      tokenizer: 'standard',
                      filter: %w(lowercase asciifolding russian_morphology english_morphology)
                  },
                  :search_analyzer => {
                      type: 'custom',
                      tokenizer: 'standard',
                      filter: %w(lowercase asciifolding russian_morphology english_morphology)
                  }
              }
          }
      }
    end

    def index_mappings
      { }.merge(additional_index_mappings)
    end

    def additional_index_mappings
      return {} unless Rails.configuration.respond_to?(:additional_index_properties)
      Rails.configuration.additional_index_properties[self.name.tableize.to_sym] || {}
    end

    def update_index
      searching_scope.find_in_batches do |batch|
        logger.info "Updating index for #{self.name} (#{batch.length} items)"
        tire.index.import batch
      end
    end

    def async_update_index
      Workers::Indexer.defer(self)
    end

    def searching_scope
      self.scoped.includes(searchable_options[:include])
    end
  end

end
