require 'elasticsearch/extensions/test/cluster'

namespace :redmine_elasticsearch do
  desc 'Starting ES test cluster'
  task :start_es do
    cluster_options = {
      port:            RedmineElasticsearch::TEST_PORT,
      number_of_nodes: 1,
      timeout:         120,
      clear_cluster:   true
    }


    if Elasticsearch::Extensions::Test::Cluster.running? cluster_options
      puts 'Stopping elasticsearch test cluster'
      Elasticsearch::Extensions::Test::Cluster.stop(port: RedmineElasticsearch::TEST_PORT)
    end

    puts 'Running the elasticsearch test cluster...'
    # Use TEST_CLUSTER_COMMAND to setup elasticsearch run command
    Elasticsearch::Extensions::Test::Cluster.start cluster_options

    # Stop test cluster after test
    Rake::Task['redmine:plugins:test:integration'].enhance do
      Rake::Task['redmine_elasticsearch:stop_es'].invoke
    end
  end

  desc 'Stopping ES test cluster'
  task :stop_es do
    puts 'Stopping elasticsearch test cluster'
    Elasticsearch::Extensions::Test::Cluster.stop(port: RedmineElasticsearch::TEST_PORT)
  end
end

# Start test ES cluster for integration tests
task 'redmine:plugins:test:integration' => 'redmine_elasticsearch:start_es'
