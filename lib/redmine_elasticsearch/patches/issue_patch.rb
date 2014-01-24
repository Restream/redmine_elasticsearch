require 'issue'

module RedmineElasticsearch::Patches::IssuePatch
  extend ActiveSupport::Concern

  included do
    include IssueSearch
  end

end

unless Issue.included_modules.include?(RedmineElasticsearch::Patches::IssuePatch)
  Issue.send :include, RedmineElasticsearch::Patches::IssuePatch
end
