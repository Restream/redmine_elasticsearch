module IssueSearch
  extend ActiveSupport::Concern
  included do
    include ApplicationSearch
  end

  def to_indexed_json
    IssueSerializer.new(self).to_json
  end

  module ClassMethods

    def index_settings
      {}
    end

    def index_mapping
      {
          issue: { properties: issue_mapping_hash }
      }
    end

    def issue_mapping_hash
      {
          id: { type: 'integer' },
          event_date: { type: 'date' },
          event_datetime: { type: 'date' },
          event_title: { type: 'string' },
          event_description: { type: 'string' },
          event_author: { type: 'string' },
          event_type: { type: 'string' },

          journals: {
              properties: {
                  id: { type: 'integer', index: 'not_analyzed' },
                  event_datetime: { type: 'date' },
                  event_description: { type: 'string' },
                  event_author: { type: 'string' }
              }
          }
      }
    end

    protected

    # search columns added by other plugins
    def additional_search_columns
      searchable_options[:columns] -
          ['subject', "#{Issue.table_name}.description", "#{Journal.table_name}.notes"]
    end

    def additional_mapping_hash
      hsh = {}
      additional_search_columns.each do |table_and_column|
        column = table_and_column.split('.')[-1].to_sym
        if table_name = table_and_column.split('.')[-2]
          table = table_name.to_sym
          assoc = self.class.reflect_on_association(table)
          if assoc.macro == :has_many
            hsh[table] ||= { :properties => {} }
            hsh[table][:properties][column] = { :type => 'string' }
          end
        else
          hsh[column] = { :type => 'string' }
        end
      end
      hsh
    end


  end
end
