module RedmineElasticsearch::Patches::RedmineSearch
  extend ActiveSupport::Concern

  included do
    class << self
      alias_method_chain :register, :elasticsearch
    end
    available_search_types.each { |search_type| include_search_methods(search_type) }
  end

  module ClassMethods
    def register_with_elasticsearch(search_type, options = {})
      include_search_methods(search_type)
      register_without_elasticsearch(search_type, options)
    end

    private

    def include_search_methods(search_type)
      search_klass = search_type.to_s.classify.constantize
      include_methods(search_klass, ApplicationSearch)
      explicit_search_methods = detect_search_methods(search_type)
      include_methods(search_klass, explicit_search_methods) if explicit_search_methods
    end

    def detect_search_methods(search_type)
      "#{search_type.to_s.classify}Search".safe_constantize
    end

    def include_methods(klass, methods)
      klass.send(:include, methods) unless klass.included_modules.include?(methods)
    end
  end
end

unless Redmine::Search.included_modules.include?(RedmineElasticsearch::Patches::RedmineSearch)
  Redmine::Search.send :include, RedmineElasticsearch::Patches::RedmineSearch
end
