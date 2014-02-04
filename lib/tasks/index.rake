namespace :redmine_elasticsearch do

  desc 'Recreate index for search type (if passed TYPE variable) or all searchable types'
  task :recreate_index => :environment do
    puts 'Recreating indexes', "Available search types are #{Redmine::Search.available_search_types}"

    search_types = if search_type = ENV['TYPE']
      Redmine::Search.available_search_types & [search_type]
    else
      Redmine::Search.available_search_types
    end

    search_types.each do |search_type|
      recreate_index_for_type(search_type)
    end

    puts 'Done recreating indexes.'
  end

  def recreate_index_for_type(search_type)
    search_klass = search_type.to_s.classify.constantize
    puts "Recreate index for #{search_type}..."
    search_klass.recreate_index
  end
end
