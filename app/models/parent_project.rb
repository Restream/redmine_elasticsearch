class ParentProject < Project
  index_name RedmineElasticsearch::INDEX_NAME

  class << self
    def recreate_index
      tire.index.delete if tire.index.exists?
      tire.index.create settings: index_settings, mappings: index_mappings
    end

    def index_settings
      {
          analysis: {
              :analyzer => {
                  :index_analyzer => {
                      type: 'custom',
                      tokenizer: 'standard',
                      filter: %w(lowercase russian_morphology english_morphology)
                  },
                  :search_analyzer => {
                      type: 'custom',
                      tokenizer: 'standard',
                      filter: %w(lowercase russian_morphology english_morphology)
                  }
              }
          }
      }
    end

    def index_mappings
      {
          parent_project: {
              _routing: { required: true, path: 'route_key' },
              properties: parent_project_mappings_hash
          }
      }
    end

    def parent_project_mappings_hash
      {
          id: { type: 'integer', index_name: 'project_id', not_analyzed: true },
          is_public: { type: 'boolean' },
          status: { type: 'integer', not_analyzed: true },
          enabled_module_names: { type: 'string', not_analyzed: true },
          route_key: { type: 'string', not_analyzed: true }
      }
    end

    def searching_scope
      self.scoped
    end
  end

end
