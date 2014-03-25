module ChangesetSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          changeset: {
                _parent: { type: 'parent_project' },
                _routing: { required: true, path: 'route_key' },
                properties: changeset_mappings_hash
          }
      }
    end

    def changeset_mappings_hash
      {
          id: { type: 'integer' },
          project_id: { type: 'integer', index: 'not_analyzed' },
          route_key: { type: 'string', not_analyzed: true },

          # acts_as_event fields
          committed_on: { type: 'date', index_name: 'datetime' },
          title: { type: 'string',
                   search_analyzer: 'search_analyzer',
                   index_analyzer: 'index_analyzer' },
          comments: { type: 'string',
                      index_name: 'description',
                      search_analyzer: 'search_analyzer',
                      index_analyzer: 'index_analyzer' },
          committer: { type: 'string', index_name: 'author' },
          url: { type: 'string', index: 'not_analyzed' },
          type: { type: 'string', index: 'not_analyzed' },

          revision: { type: 'string', index: 'not_analyzed' }
      }.merge(additional_index_mappings)
    end

    def allowed_to_search_query(user, options = {})
      options = options.merge(
          permission: :view_changesets,
          type: 'changeset'
      )
      ParentProject.allowed_to_search_query(user, options)
    end

    def searching_scope(project_id)
      self.where('project_id = ?', project_id).joins(:repository)
    end
  end
end
