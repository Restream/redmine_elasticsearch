namespace :redmine_elasticsearch do

  desc 'Recreate index to all searchable types'
  task :recreate_index => :environment do
    Redmine::Search.available_search_types.each do |search_type|
      search_klass = search_type.to_s.classify.constantize
      puts "Recreate index for #{search_type}..."
      search_klass.recreate_index
    end
  end
end
