module IssueSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def searching_scope
      self.scoped.includes(
          [:status, :project, :tracker, :author, :assigned_to, :category, :status]
      )
    end

    def index_mappings
      {
          issue: { properties: issue_mappings_hash }
      }
    end

    def issue_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },

          subject: { type: 'string' },
          description: { type: 'string' },

          created_on: { type: 'date' },
          updated_on: { type: 'date' },
          closed_on: { type: 'date' },

          author: { type: 'string' },
          assigned_to: { type: 'string' },

          category: { type: 'string' },
          status: { type: 'string' },
          done_ratio: { type: 'string', index: 'not_analyzed' },

          journals: {
              properties: {
                  id: { type: 'integer', index: 'not_analyzed' },
                  notes: { type: 'string' }
              }
          }
      }.merge(additional_index_mappings)
    end

  end
end
