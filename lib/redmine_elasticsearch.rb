module RedmineElasticsearch
end

%w{elastic serializers}.each do |fold|
  Dir[File.dirname(__FILE__) + "/#{fold}/*.rb"].each { |file| require file }
end

require 'redmine_elasticsearch/patches/search_controller_patch'

%w{Issue News}.each do |klass_name|
  require klass_name.underscore
  klass = klass_name.constantize
  search_module = "#{klass}Search".constantize
  klass.send :include, search_module unless klass.included_modules.include?(search_module)
end
