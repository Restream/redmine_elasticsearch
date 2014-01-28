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
      event_mapping_hash
    end

  end
end
