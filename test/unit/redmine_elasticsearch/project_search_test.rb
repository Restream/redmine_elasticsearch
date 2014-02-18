require File.expand_path('../../../test_helper', __FILE__)

class RedmineElasticsearch::ProjectSearchTest < ActiveSupport::TestCase
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

  def test_allowed_to_search_query_for_admin
    user = User.find_by_login('admin')
    query = Project.allowed_to_search_query(user, :search_project)
    assert_equal 'project_id:(1 2 3 4 5 6)', query
  end

  def test_allowed_to_search_query_for_jsmith
    user = User.find_by_login('jsmith')
    query = Project.allowed_to_search_query(user, :search_project)
    assert_equal 'project_id:(1 2 3 4 5 6) AND (project_id:(1 3 4 6) OR project_id:(2) OR project_id:(1 5))', query
  end

  def test_allowed_to_search_query_for_rhill
    user = User.find_by_login('rhill')
    query = Project.allowed_to_search_query(user, :search_project)
    assert_equal 'project_id:(1 2 3 4 5 6) AND (project_id:(1 3 4 6))', query
  end

end
