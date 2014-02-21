module ChangesetSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          changeset: { properties: changeset_mappings_hash }
      }
    end

    def changeset_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },

          revision: { type: 'string', index: 'not_analyzed' },
          committer: { type: 'string' },

          committed_on: { type: 'date' }

      }.merge(additional_index_mappings)
    end

    def allowed_to_search_query(user, options = {})
      options[:permission] = :view_changesets
      Project.allowed_to_search_query(user, options)
    end
  end
end
