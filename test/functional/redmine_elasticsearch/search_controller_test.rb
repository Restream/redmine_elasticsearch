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
    @project = Project.find(1)
    User.current = @user
    @request.session[:user_id] = 2
    @issue = Issue.find(1)
    @obj = TireMock.new(entity_name: :issue, entity: @issue)
    @obj.perform_stub
  end

  def test_index_success
    get :index
    assert_response :success
  end
end
