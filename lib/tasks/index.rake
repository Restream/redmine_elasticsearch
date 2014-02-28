require 'ansi/progressbar'

namespace :redmine_elasticsearch do

  desc 'Recreate index and reindex all available search types'
  task :reindex_all => :environment do
    puts 'Recreate index for all available search types'
    estimated_records = RedmineElasticsearch::IndexerService.count_estimated_records
    bar = ANSI::ProgressBar.new('Projects', estimated_records)
    bar.flush
    RedmineElasticsearch::IndexerService.reindex_all do |records|
      bar.inc(records)
    end
    bar.finish
    puts 'Done recreating index.'
  end

  desc 'Reindex search type (NAME env variable required)'
  task :reindex => :environment do
    search_type = ENV['NAME']
    raise 'Specify search type in NAME env variable' if search_type.blank?
    puts "Reindexing #{search_type} type"
    estimated_records = RedmineElasticsearch::IndexerService.count_estimated_records(search_type)
    bar = ANSI::ProgressBar.new("#{search_type}", estimated_records)
    bar.flush
    RedmineElasticsearch::IndexerService.reindex(search_type) do |records|
      bar.inc(records)
    end
    bar.finish
    puts "Done recreating #{search_type}."
  end
end
