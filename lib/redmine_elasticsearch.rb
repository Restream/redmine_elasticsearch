module RedmineElasticsearch
end

%w{elastic serializers}.each do |fold|
  fold_path = File.dirname(__FILE__) + "/../app/#{fold}"
  ActiveSupport::Dependencies.autoload_paths += [fold_path]
end

require 'redmine_elasticsearch/patches/redmine_search'
require 'redmine_elasticsearch/patches/search_controller_patch'
