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

    def include_search_methods(search_type)
      search_klass = search_type.to_s.classify.constantize
      search_methods = detect_search_methods(search_type)
      unless search_klass.included_modules.include? search_methods
        search_klass.send :include, search_methods
      end
    end

    def detect_search_methods(search_type)
      explicit_methods = "#{search_type.to_s.classify}Search"
      explicit_methods.safe_constantize || EventSearch
    end
  end
end

unless Redmine::Search.included_modules.include?(RedmineElasticsearch::Patches::RedmineSearch)
  Redmine::Search.send :include, RedmineElasticsearch::Patches::RedmineSearch
end
