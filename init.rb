require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require 'redmine_elasticsearch'
end

Redmine::Plugin.register :redmine_elasticsearch do
  name        'Full text searching plugin for Redmine'
  description 'This plugin integrates elasticsearch into Redmine'
  author      'Undev'
  version     '0.1.3'
  url         'https://github.com/Undev/redmine_elasticsearch'

  requires_redmine :version_or_higher => '2.1'
end
