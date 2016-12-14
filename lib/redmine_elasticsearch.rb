module RedmineElasticsearch
  INDEX_NAME = "#{Rails.application.class.parent_name.downcase}_#{Rails.env}"

  def self.type2class_name(type)
    type.to_s.underscore.classify
  end

  def self.type2class(type)
    self.type2class_name(type).constantize
  end
end

Tire::Configuration.url(Redmine::Configuration['elasticsearch_url'])

%w{elastic serializers}.each do |fold|
  fold_path                                  = File.dirname(__FILE__) + "/../app/#{fold}"
  ActiveSupport::Dependencies.autoload_paths += [fold_path]
end

require 'redmine_elasticsearch/patches/redmine_search'
require 'redmine_elasticsearch/patches/search_controller_patch'
require 'redmine_elasticsearch/patches/tire_patch'
