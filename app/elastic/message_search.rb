module MessageSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          message: { properties: message_mappings_hash }
      }
    end

    def message_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },

          subject: { type: 'string' },
          content: { type: 'string' },
          author: { type: 'string' },

          created_on: { type: 'date' },
          updated_on: { type: 'date' },
          replies_count: { type: 'date', index: 'not_analyzed' }

      }.merge(additional_index_mappings)
    end

  end
end
