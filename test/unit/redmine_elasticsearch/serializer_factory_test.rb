require File.expand_path('../../../test_helper', __FILE__)

class RedmineElasticsearch::SerializerFactoryTest < ActiveSupport::TestCase

  def test_get_explicit_serializer_for_issue
    issue = Issue.new
    serializer =  RedmineElasticsearch::SerializerFactory.serializer(issue)
    assert_equal IssueSerializer, serializer.class.superclass
  end

  def test_serializer_for_issue_has_event_title
    issue = Issue.new
    serializer =  RedmineElasticsearch::SerializerFactory.serializer(issue)
    assert serializer.respond_to?(:event_title)
  end

  def test_get_explicit_serializer_for_wiki_page
    wiki_page = WikiPage.new
    serializer =  RedmineElasticsearch::SerializerFactory.serializer(wiki_page)
    assert_equal WikiPageSerializer, serializer.class.superclass
  end

  def test_get_implicit_serializer_for_document
    document = Document.new
    serializer =  RedmineElasticsearch::SerializerFactory.serializer(document)
    assert_equal BaseSerializer, serializer.class.superclass
  end

  def test_serializer_for_document_has_event_title
    document = Document.new
    serializer =  RedmineElasticsearch::SerializerFactory.serializer(document)
    assert serializer.respond_to?(:event_title)
  end

  def test_serializer_for_issue_has_custom_fields

  end

  def test_serializer_for_issue_has_additional_columns

  end

end
