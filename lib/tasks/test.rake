if Rails.env.test?
  require 'elasticsearch/extensions/test/cluster'

  namespace :redmine_elasticsearch do
    desc 'Starting ES test cluster'
    task :start_test_cluster do
      if ENV['START_TEST_CLUSTER']

        if Elasticsearch::Extensions::Test::Cluster.running? RedmineElasticsearch.client_options
          puts 'Stopping elasticsearch test cluster'
          Elasticsearch::Extensions::Test::Cluster.stop(RedmineElasticsearch.client_options)
        end

        puts 'Running the elasticsearch test cluster...'
        # Use TEST_CLUSTER_COMMAND to setup elasticsearch run command
        Elasticsearch::Extensions::Test::Cluster.start RedmineElasticsearch.client_options

        # Stop test cluster after test
        Rake::Task['redmine:plugins:test:integration'].enhance do
          Rake::Task['redmine_elasticsearch:stop_test_cluster'].invoke
        end
      end
    end

    desc 'Stopping ES test cluster'
    task :stop_test_cluster do
      puts 'Stopping elasticsearch test cluster'
      Elasticsearch::Extensions::Test::Cluster.stop(RedmineElasticsearch.client_options)
    end
  end

  # Start test ES cluster for integration tests
  task 'redmine:plugins:test:integration' => 'redmine_elasticsearch:start_test_cluster'
end
