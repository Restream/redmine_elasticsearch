module RedmineElasticsearch::SerializerExt::Searchable
  extend ActiveSupport::Concern

  # search columns added by other plugins
  def additional_search_columns
    object.class.searchable_options[:columns]
  end

end
