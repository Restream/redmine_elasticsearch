require File.expand_path(File.dirname(__FILE__) + '../../../../test/test_helper')

class ActiveSupport::TestCase
  def search_all_for_klass(klass, user, options = {})
    klass_query = klass.allowed_to_search_query(user)
    options.reverse_merge(
        :load => true,
        :size => klass.count
    )
    search = Tire.search(klass.index_name, options) { query { string klass_query } }
    search.results
  end
end
