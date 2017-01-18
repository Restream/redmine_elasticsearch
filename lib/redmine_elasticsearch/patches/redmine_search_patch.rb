require 'redmine/search'

module RedmineElasticsearch
  module Patches
    module RedmineSearchPatch

      def self.prepended(base)
        base.class_eval do

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

          extend ClassMethods

          update_search_methods
        end
      end

      module ClassMethods

        # Registers a search provider
        def register(search_type, options={})
          include_search_methods(search_type)
          super
        end

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
  end
end
