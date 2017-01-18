require File.expand_path('../../../test_helper', __FILE__)

# Just as in redmine search test
class RedmineElasticsearch::ApiSearchTest < Redmine::ApiTest::Base
  fixtures :projects,
    :users,
    :email_addresses,
    :roles,
    :members,
    :member_roles,
    :issues,
    :journals,
    :journal_details,
    :issue_statuses,
    :versions,
    :trackers,
    :projects_trackers,
    :issue_categories,
    :enabled_modules,
    :enumerations,
    :news,
    :documents,
    :changesets,
    :repositories,
    :wikis,
    :wiki_pages,
    :messages,
    :boards

  def setup
    RedmineElasticsearch::IndexerService.reindex_all
  end

  test "GET /search.xml should return xml content" do
    get '/search.xml'

    assert_response :success
    assert_equal 'application/xml', @response.content_type
  end

  test "GET /search.json should return json content" do
    get '/search.json'

    assert_response :success
    assert_equal 'application/json', @response.content_type

    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_kind_of Array, json['results']
  end

  test "GET /search.xml without query strings should return empty results" do
    get '/search.xml', :q => '', :all_words => ''

    assert_response :success
    assert_equal 0, assigns(:results).size
  end

  test "GET /search.xml with query strings should return results" do
    get '/search.xml', :q => 'recipe subproject commit', :all_words => ''

    assert_response :success
    assert_not_empty(assigns(:results))

    assert_select 'results[type=array]' do
      assert_select 'result', :count => assigns(:results).count
      assigns(:results).size.times.each do |i|
        assert_select 'result' do
          assert_select 'id',          :text => assigns(:results)[i].id.to_s
          assert_select 'title',       :text => assigns(:results)[i].event_title
          assert_select 'type',        :text => assigns(:results)[i].event_type
          assert_select 'url',         :text => url_for(assigns(:results)[i].event_url(:only_path => false))
          assert_select 'description', :text => assigns(:results)[i].event_description
          assert_select 'datetime'
        end
      end
    end
  end

  test "GET /search.json should paginate" do
    issue = (0..10).map {Issue.generate! :subject => 'search_with_limited_results'}.reverse.map(&:id)
    RedmineElasticsearch.refresh_indices

    get '/search.json', :q => 'search_with_limited_results', :limit => 4
    json = ActiveSupport::JSON.decode(response.body)
    assert_equal 11, json['total_count']
    assert_equal 0, json['offset']
    assert_equal 4, json['limit']
    assert_equal issue[0..3], json['results'].map {|r| r['id'].to_i }

    get '/search.json', :q => 'search_with_limited_results', :offset => 8, :limit => 4
    json = ActiveSupport::JSON.decode(response.body)
    assert_equal 11, json['total_count']
    assert_equal 8, json['offset']
    assert_equal 4, json['limit']
    assert_equal issue[8..10], json['results'].map {|r| r['id'].to_i }
  end

  test "search should find text in journal" do
    # Will search for note -> "A comment with inline image: !picture.jpg! and a reference to #1 and r2."
    get '/search.json', q: 'reference', issues: true
    json = ActiveSupport::JSON.decode(response.body)
    assert_equal 1, json['total_count']
    assert_equal [2], json['results'].map {|r| r['id'].to_i }
  end

end
