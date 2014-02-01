class IssueSerializer < BaseSerializer
  has_many :journals, serializer: BaseSerializer

  # override additional_search_columns to remove already indexed issue attributes
  def additional_search_columns
    object.class.searchable_options[:columns] -
        ['subject', "#{Issue.table_name}.description", "#{Journal.table_name}.notes"]
  end
end
