require File.expand_path('../../../test_helper', __FILE__)

class RedmineElasticsearch::SearchTest < Redmine::IntegrationTest
  fixtures :projects,
    :users,
    :email_addresses,
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

  test 'only allowed issues will found' do
    assert_search_only_allowed_items(
      query:    ->(user) { Issue.allowed_to_search_query(user) },
      expected: ->(user) { Issue.visible(user) }
    )
  end

  test 'only allowed news will found' do
    assert_search_only_allowed_items(
      query:    ->(user) { News.allowed_to_search_query(user) },
      expected: ->(user) { News.visible(user) }
    )
  end

  test 'only allowed documents will found' do
    assert_search_only_allowed_items(
      query:    ->(user) { Document.allowed_to_search_query(user) },
      expected: ->(user) { Document.visible(user) }
    )
  end

  test 'only allowed changesets will found' do
    assert_search_only_allowed_items(
      query:    ->(user) { Changeset.allowed_to_search_query(user) },
      expected: ->(user) { Changeset.visible(user) }
    )
  end

  test 'only allowed wiki_pages will found' do
    assert_search_only_allowed_items(
      query:    ->(user) { WikiPage.allowed_to_search_query(user) },
      expected: ->(user) { WikiPage.all.to_a.select { |wiki_page| wiki_page.visible?(user) } }
    )
  end

  test 'only allowed messages will found' do
    assert_search_only_allowed_items(
      query:    ->(user) { Message.allowed_to_search_query(user) },
      expected: ->(user) { Message.visible(user) }
    )
  end

  test 'only allowed projects will found' do
    assert_search_only_allowed_items(
      query:    ->(user) { Project.allowed_to_search_query(user) },
      expected: ->(user) { Project.visible(user) }
    )
  end

  test 'search all issues without errors' do
    get '/search', { q: '*' }, credentials('admin')

    assert_response :success
  end

  private

  def assert_search_only_allowed_items(query:, expected:)
    # For each user
    ([User.anonymous] + User.all).each do |user|
      expected_items = expected.call(user)
      payload        = {
        size:  expected_items.length + 10, # allow to return more results as expected
        query: query.call(user)
      }
      found          = Elasticsearch::Model.search(payload).to_a
      found_ids      = found.map { |item| item._id.to_i }.sort
      expected_ids   = expected_items.map(&:id).sort
      assert_equal expected_ids, found_ids, "Found ids are not the same as expected ids for user '#{user.name}'"
    end
  end

end
