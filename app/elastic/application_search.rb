module ApplicationSearch
  extend ActiveSupport::Concern

  included do
    include Tire::Model::Search

    index_name RedmineElasticsearch::INDEX_NAME

    after_commit :async_update_index
  end

  def to_indexed_json
    RedmineElasticsearch::SerializerService.serialize_to_json(self)
  end

  def async_update_index
    Workers::Indexer.defer(self)
  end

  module ClassMethods

    def index_mappings
      { }.merge(additional_index_mappings)
    end

    def additional_index_mappings
      return {} unless Rails.configuration.respond_to?(:additional_index_properties)
      Rails.configuration.additional_index_properties[self.name.tableize.to_sym] || {}
    end

    def update_mapping
      index_mappings.each do |k, v|
        index.mapping! k, v
      end
    end

    def searching_scope(project_id)
      self.where('project_id = ?', project_id)
    end
  end

end
