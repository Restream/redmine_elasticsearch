require File.expand_path('../../../test_helper', __FILE__)

class RedmineElasticsearch::SerializerServiceTest < ActiveSupport::TestCase

  def setup
    # clear cache
    RedmineElasticsearch::SerializerService.class_eval do
      @serializers = nil
    end
  end

  def test_get_explicit_serializer
    issue      = Issue.new
    serializer = RedmineElasticsearch::SerializerService.serializer(issue)
    assert_kind_of IssueSerializer, serializer
  end

  def test_serializer_has_additional_attributes
    Rails.configuration.stubs(:additional_index_properties).returns(
      issues: {
        foo: { type: 'string' },
        bar: {
          properties: {
            name: { type: 'string' }
          }
        }
      }
    )
    issue      = Issue.new
    serializer = RedmineElasticsearch::SerializerService.serializer(issue)
    assert serializer.respond_to?(:foo)
    assert serializer.respond_to?(:bar)
  ensure
    Rails.configuration.stubs(:additional_index_properties).returns({})
  end

  def test_get_implicit_serializer
    object     = IssueStatus.new
    serializer = RedmineElasticsearch::SerializerService.serializer(object)
    assert_kind_of BaseSerializer, serializer
  end

  def test_serializer_classes_are_cached
    object      = Issue.new
    serializer1 = RedmineElasticsearch::SerializerService.serializer(object)
    serializer2 = RedmineElasticsearch::SerializerService.serializer(object)
    assert_not_equal serializer1, serializer2
    assert_equal serializer1.class, serializer2.class
  end

  def test_create_serializer_with_custom_klass
    object      = Project.new
    serializer = RedmineElasticsearch::SerializerService.serializer(object, ParentProjectSerializer)
    assert_kind_of ParentProjectSerializer, serializer
  end

end
