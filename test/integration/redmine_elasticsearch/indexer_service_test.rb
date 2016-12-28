require File.expand_path('../../../test_helper', __FILE__)

class RedmineElasticsearch::IndexerServiceTest < Redmine::IntegrationTest
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
    if RedmineElasticsearch.client.indices.exists? index: RedmineElasticsearch::INDEX_NAME
      RedmineElasticsearch.client.indices.delete index: RedmineElasticsearch::INDEX_NAME
    end
  end

  def test_recreate_index
    refute RedmineElasticsearch.client.indices.exists? index: RedmineElasticsearch::INDEX_NAME
    assert_nothing_raised do
      RedmineElasticsearch::IndexerService.recreate_index
    end
    assert RedmineElasticsearch.client.indices.exists? index: RedmineElasticsearch::INDEX_NAME
  end

  def test_reindex_all
    refute RedmineElasticsearch.client.indices.exists? index: RedmineElasticsearch::INDEX_NAME
    assert_nothing_raised do
      RedmineElasticsearch::IndexerService.reindex_all
    end
    assert RedmineElasticsearch.client.indices.exists? index: RedmineElasticsearch::INDEX_NAME
    refute Issue.all.empty?
    found_records = Elasticsearch::Model.search('*',[Issue]).results.total
    assert_equal Issue.count, found_records

    Redmine::Search.available_search_types.each do |type|
      klass = RedmineElasticsearch.type2class(type)
      refute klass.all.empty?, "#{ klass.to_s } should contains some records for test"
      found_records = Elasticsearch::Model.search('*',[klass]).results.total
      assert_equal klass.count, found_records, "Search all in #{ klass.to_s } should returns #{ klass.count } results."
    end
  end

end