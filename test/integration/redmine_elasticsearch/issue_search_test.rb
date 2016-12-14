require File.expand_path('../../../test_helper', __FILE__)

class RedmineElasticsearch::IssueSearchTest < ActionController::IntegrationTest
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations

  def setup
    stub_index_settings
    RedmineElasticsearch::IndexerService.reindex_all
  end

  def test_allowed_to_search_query_for_users
    ([User.anonymous] + User.all).each do |user|
      found       = search_all_for_klass(Issue, user)
      found_ids   = found.map { |e| e.id.to_i }.sort
      visible_ids = Issue.visible(user).map(&:id).sort
      assert_equal visible_ids, found_ids, "Found ids are not the same as visible ids for user: '#{user.name}'"
    end
  end
end
