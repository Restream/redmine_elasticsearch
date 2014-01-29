module IssueSearch
  extend ActiveSupport::Concern
  included do
    include ApplicationSearch

    def to_indexed_json
      IssueSerializer.new(self).to_json
    end

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
      event_mapping_hash.merge(
          journals: {
              properties: {
                  id: { type: 'integer', index: 'not_analyzed' },
                  event_date: { type: 'date' },
                  event_datetime: { type: 'date' },
                  event_title: { type: 'string' },
                  event_description: { type: 'string' },
                  event_author: { type: 'string' },
                  event_type: { type: 'string' }
              }
          }
      )
    end

  end
end
