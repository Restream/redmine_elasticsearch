module RedmineElasticsearch::Patches::RedmineSearch
  extend ActiveSupport::Concern

  included do
    # watching for changing size of available_search_types
    class << available_search_types
      Array.instance_methods(false).each do |meth|
        old = instance_method(meth)
        define_method(meth) do |*args, &block|
          old_size = size
          old.bind(self).call(*args, &block)
          Redmine::Search.update_search_methods if old_size != size
        end if [:add, :<<].include?(meth)
      end
    end

    update_search_methods
  end

  module ClassMethods
    def update_search_methods
      available_search_types.each { |search_type| include_search_methods(search_type) } if available_search_types
    end

    private

    def include_search_methods(search_type)
      search_klass = RedmineElasticsearch.type2class(search_type)
      include_methods(search_klass, ::ApplicationSearch)
      explicit_search_methods = detect_search_methods(search_type)
      include_methods(search_klass, explicit_search_methods) if explicit_search_methods
    end

    def detect_search_methods(search_type)
      "::#{RedmineElasticsearch.type2class_name(search_type)}Search".safe_constantize
    end

    def include_methods(klass, methods)
      klass.send(:include, methods) unless klass.included_modules.include?(methods)
    end
  end
end

unless Redmine::Search.included_modules.include?(RedmineElasticsearch::Patches::RedmineSearch)
  Redmine::Search.send :include, RedmineElasticsearch::Patches::RedmineSearch
end
