#encoding: utf-8

class ParentProject < Project
  index_name RedmineElasticsearch::INDEX_NAME

  class << self
    def index_settings
      {
          analysis: {
              analyzer: {
                  index_analyzer: {
                      type: 'custom',
                      tokenizer: 'standard',
                      filter: %w(lowercase main_ngrams russian_morphology english_morphology main_stopwords)
                  },
                  search_analyzer: {
                      type: 'custom',
                      tokenizer: 'standard',
                      filter: %w(lowercase russian_morphology english_morphology main_stopwords)
                  }
              },
              filter: {
                  main_stopwords: {
                      type: 'stop',
                      stopwords: %(а без более бы был была были было быть в вам вас весь во вот все всего всех вы где да даже для до его ее если есть еще же за здесь и из или им их к как ко когда кто ли либо мне может мы на надо наш не него нее нет ни них но ну о об однако он она они оно от очень по под при с со так также такой там те тем то того тоже той только том ты у уже хотя чего чей чем что чтобы чье чья эта эти это я a an and are as at be but by for if in into is it no not of on or such that the their then there these they this to was will with)
                  },
                  main_ngrams: {
                      type: 'edgeNGram',
                      min_gram: 1,
                      max_gram: 20
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
          status_id: { type: 'integer', not_analyzed: true },
          enabled_module_names: { type: 'string', not_analyzed: true },
          route_key: { type: 'string', not_analyzed: true }
      }
    end

    def searching_scope
      self.scoped
    end

    def allowed_to_search_query(user, options = {})
      permission = options[:permission] || :search_project
      perm = Redmine::AccessControl.permission(permission)

      must_queries = []

      # If the permission belongs to a project module, make sure the module is enabled
      if perm && perm.project_module
        must_queries << {
            has_parent: {
                type: 'parent_project',
                query: { term: { enabled_module_names: { value: perm.project_module } } }
            }
        }
      end

      must_queries << { term: { _type: options[:type] } } if options[:type].present?

      unless user.admin?
        statement_by_role = {}
        role = user.logged? ? Role.non_member : Role.anonymous
        hide_public_projects = user.pref[:hide_public_projects] == '1'
        if role.allowed_to?(permission) && !hide_public_projects
          statement_by_role[role] = {
              has_parent: {
                  type: 'parent_project',
                  query: { term: { is_public: { value: true } } }
              }
          }
        end
        if user.logged?
          user.projects_by_role.each do |role, projects|
            if role.allowed_to?(permission) && projects.any?
              statement_by_role[role] = {
                  has_parent: {
                      type: 'parent_project',
                      query: { ids: { values: projects.collect(&:id) } }
                  }
              }
            end
          end
        end
        if statement_by_role.empty?
          must_queries = [{ term: { id: { value: 0 } } }]
        else
          if block_given?
            statement_by_role.each do |role, statement|
              block_statement = yield(role, user)
              if block_statement.present?
                statement_by_role[role] = {
                    bool: {
                        must: [statement, block_statement]
                    }
                }
              end
            end
          end
          must_queries << { bool: { should: statement_by_role.values, minimum_should_match: 1 } }
        end
      end
      {
          bool: {
              must: must_queries
          }
      }
    end

  end

end
