require File.expand_path('../../../test_helper', __FILE__)

class RedmineElasticsearch::SearchControllerTest < ActionController::TestCase
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
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user = User.find(2)
    User.current = @user
    @request.session[:user_id] = 2
    klass = nil
    Redmine::Search.available_search_types.each do |search_type|
      klass = search_type.to_s.classify.constantize
      klass.recreate_index
    end
    klass.index.refresh
  end

  def test_index_success
    get :index, :q => '*'
    assert_response :success
  end
end
