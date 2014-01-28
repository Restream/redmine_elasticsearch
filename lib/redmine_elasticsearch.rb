module RedmineElasticsearch
end

%w{elastic serializers}.each do |fold|
  Dir[File.dirname(__FILE__) + "/../app/#{fold}/*.rb"].each { |file| require_dependency file }
end

require 'redmine_elasticsearch/patches/redmine_search'
require 'redmine_elasticsearch/patches/search_controller_patch'
