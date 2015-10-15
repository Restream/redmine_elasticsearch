require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require 'redmine_elasticsearch'
end

Redmine::Plugin.register :redmine_elasticsearch do
  name        'Redmine Elasticsearch Plugin'
  description 'This plugin integrates the Elasticsearch full-text search engine into Redmine.'
  author      'Undev'
  version     '0.1.13'
  url         'https://github.com/Undev/redmine_elasticsearch'

  requires_redmine :version_or_higher => '2.1'
end
