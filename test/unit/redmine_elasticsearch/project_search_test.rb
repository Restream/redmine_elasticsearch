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
    query = Project.allowed_to_search_query(user)
    ids = query.scan(/\d+/).map(&:to_i).sort.uniq
    assert_equal [1, 2, 3, 4, 5, 6], ids
  end

  def test_allowed_to_search_query_for_jsmith
    user = User.find_by_login('jsmith')
    query = Project.allowed_to_search_query(user)
    base, opt = query.split(' AND ')
    base_ids = base.scan(/\d+/).map(&:to_i).sort.uniq
    opt_ids = opt.scan(/\d+/).map(&:to_i).sort.uniq
    assert_equal [1, 2, 3, 4, 5, 6], base_ids
    assert_equal [1, 2, 3, 4, 5, 6], opt_ids
  end

  def test_allowed_to_search_query_for_rhill
    user = User.find_by_login('rhill')
    query = Project.allowed_to_search_query(user)
    base, opt = query.split(' AND ')
    base_ids = base.scan(/\d+/).map(&:to_i).sort.uniq
    opt_ids = opt.scan(/\d+/).map(&:to_i).sort.uniq
    assert_equal [1, 2, 3, 4, 5, 6], base_ids
    assert_equal [1, 3, 4, 6], opt_ids
  end

  def test_allowed_to_search_query_for_anonymous
    user = User.anonymous
    query = Project.allowed_to_search_query(user)
    base, opt = query.split(' AND ')
    base_ids = base.scan(/\d+/).map(&:to_i).sort.uniq
    opt_ids = opt.scan(/\d+/).map(&:to_i).sort.uniq
    assert_equal [1, 2, 3, 4, 5, 6], base_ids
    assert_equal [1, 3, 4, 6], opt_ids
  end

  def test_allowed_to_search_query_for_explicit_projects
    user = User.find_by_login('admin')
    query = Project.allowed_to_search_query(user, :project_ids => [3, 4, 5])
    ids = query.scan(/\d+/).map(&:to_i).sort.uniq
    assert_equal [3, 4, 5], ids
  end

  def test_allowed_to_search_query_for_empty_explicit_projects
    user = User.find_by_login('admin')
    query = Project.allowed_to_search_query(user, :project_ids => [])
    empty_braces = (query =~ /\(\)/)
    assert_nil empty_braces
  end

end
