require 'elasticsearch'
require 'elasticsearch/model'

module RedmineElasticsearch
  INDEX_NAME            = "#{Rails.application.class.parent_name.downcase}_#{Rails.env}"
  TEST_PORT             = 9250
  BATCH_SIZE_FOR_IMPORT = 300

  def type2class_name(type)
    type.to_s.underscore.classify
  end

  def type2class(type)
    self.type2class_name(type).constantize
  end

  def search_klasses
    Redmine::Search.available_search_types.map { |type| type2class(type) }
  end

  def apply_patch(patch, *targets)
    targets = Array(targets).flatten
    targets.each do |target|
      unless target.included_modules.include? patch
        target.send :prepend, patch
      end
    end
  end

  def additional_index_properties(document_type)
    @additional_index_properties                = {}
    @additional_index_properties[document_type] ||= begin
      Rails.configuration.respond_to?(:additional_index_properties) ?
        Rails.configuration.additional_index_properties.fetch(document_type, {}) : {}
    end
  end

  def client
    @client ||= Elasticsearch::Client.new Redmine::Configuration['elasticsearch'] || { request_timeout: 180 }
  end

  # Refresh the index and to make the changes (creates, updates, deletes) searchable.
  def refresh_indices
    client.indices.refresh
  end

  extend self
end

%w{elastic serializers}.each do |fold|
  fold_path                                  = File.dirname(__FILE__) + "/../app/#{fold}"
  ActiveSupport::Dependencies.autoload_paths += [fold_path]
end

require_dependency 'redmine_elasticsearch/patches/redmine_search_patch'
require_dependency 'redmine_elasticsearch/patches/search_controller_patch'

ActionDispatch::Callbacks.to_prepare do
  RedmineElasticsearch.apply_patch RedmineElasticsearch::Patches::RedmineSearchPatch, Redmine::Search
  RedmineElasticsearch.apply_patch RedmineElasticsearch::Patches::SearchControllerPatch, SearchController
  RedmineElasticsearch.apply_patch RedmineElasticsearch::Patches::ResponseResultsPatch, Elasticsearch::Model::Response::Results

  # Using plugin's configured client in all models
  Elasticsearch::Model.client = RedmineElasticsearch.client
end
