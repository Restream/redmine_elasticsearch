require 'elasticsearch'
require 'elasticsearch/model'

module RedmineElasticsearch
  INDEX_NAME = "#{Rails.application.class.parent_name.downcase}_#{Rails.env}"
  TEST_PORT  = 9250

  def self.type2class_name(type)
    type.to_s.underscore.classify
  end

  def self.type2class(type)
    self.type2class_name(type).constantize
  end

  def self.apply_patch(patch, *targets)
    targets = Array(targets).flatten
    targets.each do |target|
      unless target.included_modules.include? patch
        target.send :include, patch
      end
    end
  end

  def self.additional_mapping_for(document_type)
    @additional_mapping                = {}
    @additional_mapping[document_type] ||= begin
      Rails.configuration.respond_to?(:additional_index_properties) ?
        Rails.configuration.additional_index_properties.fetch(document_type, {}) : {}
    end
  end

  def self.client
    # TODO: get url from config: Redmine::Configuration['elasticsearch_url'] or plugin settings
    @client ||= begin
      options = { log: true }
      if Rails.env == 'test'
        options[:host] = 'localhost'
        options[:port] = TEST_PORT
      end
      Elasticsearch::Client.new options
    end
  end
end

%w{elastic serializers}.each do |fold|
  fold_path                                  = File.dirname(__FILE__) + "/../app/#{fold}"
  ActiveSupport::Dependencies.autoload_paths += [fold_path]
end

require_dependency 'redmine_elasticsearch/patches/redmine_search'
require_dependency 'redmine_elasticsearch/patches/search_controller_patch'

ActionDispatch::Callbacks.to_prepare do
  RedmineElasticsearch.apply_patch RedmineElasticsearch::Patches::RedmineSearch, Redmine::Search
  RedmineElasticsearch.apply_patch RedmineElasticsearch::Patches::SearchControllerPatch, SearchController
end
