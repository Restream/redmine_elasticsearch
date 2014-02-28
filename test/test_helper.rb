require File.expand_path(File.dirname(__FILE__) + '../../../../test/test_helper')

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

  def stub_index_settings
    ParentProject.stubs(:index_settings).returns(
        {
            index: {
                store: { type: :memory },
                number_of_shards: 1,
                number_of_replicas: 0
            },
            analysis: {
                analyzer: {
                    :index_analyzer => {
                        type: 'custom',
                        tokenizer: 'standard',
                        filter: %w(lowercase)
                    },
                    :search_analyzer => {
                        type: 'custom',
                        tokenizer: 'standard',
                        filter: %w(lowercase)
                    }
                }
            }
        }
    )
  end
end
