require 'elasticsearch/extensions/test/cluster'

namespace :redmine_elasticsearch do
  desc 'Starting ES test cluster'
  task :start_es do
    # Use TEST_CLUSTER_COMMAND to setup elasticsearch run command
    Elasticsearch::Extensions::Test::Cluster.start(
      port:            RedmineElasticsearch::TEST_PORT,
      number_of_nodes: 1,
      timeout:         120,
      clear_cluster:   true
    )
    Rake::Task['redmine:plugins:test:integration'].enhance do
      Rake::Task['redmine_elasticsearch:stop_es'].invoke
    end
  end

  desc 'Stopping ES test cluster'
  task :stop_es do
    Elasticsearch::Extensions::Test::Cluster.stop(port: RedmineElasticsearch::TEST_PORT)
  end
end

# Start test ES cluster for integration tests
task 'redmine:plugins:test:integration' => 'redmine_elasticsearch:start_es'
