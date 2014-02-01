require 'redmine_elasticsearch/serializer_ext/event'
require 'redmine_elasticsearch/serializer_ext/searchable'

class RedmineElasticsearch::SerializerFactory
  attr_reader :object

  class << self
    def serializer(object)
      instance = self.new(object)
      instance.serializer
    end
  end

  def initialize(object)
    @object = object
  end

  def serializer
    klass = Class.new(explicit_serializer || BaseSerializer)
    klass.send :include, RedmineElasticsearch::SerializerExt::Event if acts_as_event?
    klass.send :include, RedmineElasticsearch::SerializerExt::Searchable if acts_as_searchable?
    klass.new(object)
  end

  private

  def explicit_serializer
    "#{object.class.name.classify}Serializer".safe_constantize
  end

  def acts_as_event?
    object.class.included_modules.include?(Redmine::Acts::Event)
  end

  def acts_as_searchable?
    object.class.included_modules.include?(Redmine::Acts::Searchable)
  end
end
