require 'ansi/progressbar'

namespace :redmine_elasticsearch do

  desc 'Recreate index'
  task :recreate_index => :environment do
    puts 'Recreate index for all available search types'
    RedmineElasticsearch::IndexerService.recreate_index
    puts 'Done recreating index.'
  end

  desc 'Recreate index and reindex all available search types (BATCH_SIZE env variable is optional)'
  task :reindex_all => :environment do
    puts 'Recreate index for all available search types'
    estimated_records = RedmineElasticsearch::IndexerService.count_estimated_records
    bar = ANSI::ProgressBar.new('Projects', estimated_records)
    bar.flush
    RedmineElasticsearch::IndexerService.reindex_all(batch_size: batch_size) do |records|
      bar.inc(records)
    end
    bar.finish
    puts 'Done reindex all.'
  end

  desc 'Reindex search type (NAME env variable is required, BATCH_SIZE is optional)'
  task :reindex => :environment do
    search_type = ENV['NAME']
    raise 'Specify search type in NAME env variable' if search_type.blank?
    puts "Reindexing #{search_type} type"
    estimated_records = RedmineElasticsearch::IndexerService.count_estimated_records(search_type)
    bar = ANSI::ProgressBar.new("#{search_type}", estimated_records)
    bar.flush
    RedmineElasticsearch::IndexerService.reindex(search_type, batch_size: batch_size) do |records|
      bar.inc(records)
    end
    bar.finish
    puts "Done reindex #{search_type}."
  end

  def batch_size
    ENV['BATCH_SIZE'].present? ? ENV['BATCH_SIZE'].to_i : nil
  end
end
