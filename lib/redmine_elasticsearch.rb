module RedmineElasticsearch
end

%w{elastic serializers}.each do |fold|
  Dir[File.dirname(__FILE__) + "/#{fold}/*.rb"].each { |file| require file }
end

require 'redmine_elasticsearch/patches/search_controller_patch'
require 'redmine_elasticsearch/patches/issue_patch'
