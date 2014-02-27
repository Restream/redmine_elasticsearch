require File.expand_path(File.dirname(__FILE__) + '../../../../test/test_helper')

Redmine::Search.available_search_types.each do |search_type|
  klass = search_type.to_s.classify.constantize
  klass.class_eval do
    def self.index_settings
      { index: { store: { type: :memory } } }
    end
  end
end

class ActiveSupport::TestCase
  def search_all_for_klass(klass, user, options = {})
    type_query = klass.allowed_to_search_query(user)
    options.reverse_merge!(
        load: true,
        size: klass.count,
        payload: { query: type_query }
    )
    search = Tire.search(klass.index_name, options)
    search.results
  end
end
