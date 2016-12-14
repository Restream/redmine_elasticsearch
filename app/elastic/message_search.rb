module MessageSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
        message: {
          _parent:    { type: 'parent_project' },
          _routing:   { required: true, path: 'route_key' },
          properties: message_mappings_hash
        }
      }
    end

    def message_mappings_hash
      {
        id:            { type: 'integer' },
        project_id:    { type: 'integer', index: 'not_analyzed' },
        route_key:     { type: 'string', not_analyzed: true },

        # acts_as_event fields
        created_on:    { type: 'date', index_name: 'datetime' },
        subject:       { type:            'string',
                         index_name:      'title',
                         search_analyzer: 'search_analyzer',
                         index_analyzer:  'index_analyzer' },
        content:       { type:            'string',
                         index_name:      'description',
                         search_analyzer: 'search_analyzer',
                         index_analyzer:  'index_analyzer' },
        author:        { type: 'string' },
        url:           { type: 'string', index: 'not_analyzed' },
        type:          { type: 'string', index: 'not_analyzed' },

        updated_on:    { type: 'date' },
        replies_count: { type: 'integer', index: 'not_analyzed' }
      }.merge(additional_index_mappings).merge(attachments_mappings)
    end

    def allowed_to_search_query(user, options = {})
      options = options.merge(
        permission: :view_messages,
        type:       'message'
      )
      ParentProject.allowed_to_search_query(user, options)
    end

    def searching_scope(project_id)
      self.where('project_id = ?', project_id).joins(:board)
    end
  end
end
