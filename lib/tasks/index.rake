require 'ansi/progressbar'

namespace :redmine_elasticsearch do

  desc 'Recreate index for all available search types'
  task :reindex => :environment do
    puts 'Recreate index for all available search types'
    projects_count = ParentProject.searching_scope.count
    pbar = ANSI::Progressbar.new('Projects', projects_count)
    RedmineElasticsearch::IndexerService.reindex_all do
      pbar.inc
    end
    pbar.finish
    puts 'Done recreating index.'
  end
end
