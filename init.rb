require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require 'redmine_elasticsearch'
end

Redmine::Plugin.register :redmine_elasticsearch do
  name        'Redmine Elasticsearch Plugin'
  description 'This plugin integrates the Elasticsearch full-text search engine into Redmine.'
  author      'Restream'
  version     '0.2.0'
  url         'https://github.com/Restream/redmine_elasticsearch'

  requires_redmine version_or_higher: '2.1'
end
