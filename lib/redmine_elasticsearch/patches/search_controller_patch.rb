require 'active_support/concern'
require 'search_controller'

module RedmineElasticsearch::Patches::SearchControllerPatch
  extend ActiveSupport::Concern

  included do
    alias_method_chain :index, :elasticsearch

    RESULT_SIZE = 10
  end

  def index_with_elasticsearch
    get_variables_from_params

    if issue = detect_issue_in_question(@question)
      # quick jump to an issue
      redirect_to issue_path(issue)
    else
      # First searching with advanced query with parsing it on elasticsearch side.
      # If it fails then use match query.
      # http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-match-query.html#_comparison_to_query_string_field
      # The match family of queries does not go through a "query parsing" process.
      # It does not support field name prefixes, wildcard characters, or other "advance" features.
      # For this reason, chances of it failing are very small / non existent,
      # and it provides an excellent behavior when it comes to just analyze and
      # run that text as a query behavior (which is usually what a text search box does).
      search_options = {
          :scope => @scope,
          :q => @question,
          :titles_only => @titles_only,
          :all_words => @all_words,
          :page => params[:page] || 1,
          :size => RESULT_SIZE,
          :projects => @projects_to_search
      }
      begin
        search_options[:search_type] = :query_string
        @results = perform_search(search_options)
      rescue Tire::Search::SearchRequestFailed => e
        logger.debug e
        search_options[:search_type] = :match
        @results = perform_search(search_options)
      end
      @search_type = search_options[:search_type]
      @results_by_type = get_results_by_type_from_search_results(@results)
      render :layout => false if request.xhr?
    end
  rescue Errno::ECONNREFUSED => e
    logger.error e
    render_error :message => :search_connection_refused, :status => 503
  end

  private

  def get_variables_from_params
    @question = params[:q] || ''
    @question.strip!
    @all_words = params[:all_words] ? params[:all_words].present? : true
    @titles_only = params[:titles_only] ? params[:titles_only].present? : false
    @projects_to_search = get_projects_from_params
    @object_types = allowed_object_types(@projects_to_search)
    @scope = filter_object_types_from_params(@object_types)

    # extract tokens from the question
    # eg. hello "bye bye" => ["hello", "bye bye"]
    @tokens = @question.scan(%r{((\s|^)"[\s\w]+"(\s|$)|\S+)}).collect {|m| m.first.gsub(%r{(^\s*"\s*|\s*"\s*$)}, '')}
    # tokens must be at least 2 characters long
    @tokens = @tokens.uniq.select {|w| w.length > 1 }
  end

  def detect_issue_in_question(question)
    (m = question.match(/^#?(\d+)$/)) && Issue.visible.find_by_id(m[1].to_i)
  end

  def get_projects_from_params
    case params[:scope]
      when 'all'
        nil
      when 'my_projects'
        User.current.memberships.collect(&:project)
      when 'subprojects'
        @project ? (@project.self_and_descendants.active.all) : nil
      else
        @project
    end
  end

  def allowed_object_types(projects_to_search)
    object_types = Redmine::Search.available_search_types.dup
    if projects_to_search.is_a? Project
      # don't search projects
      object_types.delete('projects')
      # only show what the user is allowed to view
      object_types = object_types.select { |o| User.current.allowed_to?("view_#{o}".to_sym, projects_to_search) }
    end
    object_types
  end

  def filter_object_types_from_params(object_types)
    scope = object_types.select { |t| params[t] }
    scope = object_types if scope.empty?
    scope
  end

  def perform_search(options = {})
    #todo: refactor this
    project_ids = options[:projects] ? [options[:projects]].flatten.compact.map(&:id) : nil

    common_must = []

    search_fields = options[:titles_only] ? ['title'] : %w(title description notes)
    search_operator = options[:all_words] ? 'and' : 'or'
    main_query = case options[:search_type]
      when :query_string
        {
            query_string: {
                query: options[:q],
                default_operator: search_operator,
                fields: search_fields,
                use_dis_max: true
            }
        }
      when :match
        {
            multi_match: {
                query: options[:q],
                operator: search_operator,
                fields: search_fields,
                use_dis_max: true
            }
        }
      else
        raise "Unknown search_type: #{options[:search_type].inspect}"
    end

    # add nested_query for searching in attachments
    main_query = {
        bool: {
            should: [
                main_query,
                {
                    nested: {
                        path: 'attachments',
                        query: main_query
                    }
                }
            ]
        }
    } unless options[:titles_only]

    common_must << main_query

    document_types = options[:scope].map(&:singularize)
    common_must << { terms: { _type: document_types} }

    if project_ids
      common_must << {
          has_parent: {
              type: 'parent_project',
              query: { ids: { values: project_ids } }
          }
      }
    end

    common_must_not = []

    common_must_not << {
        has_parent: {
            type: 'parent_project',
            query: { term: { status_id: { value: Project::STATUS_ARCHIVED } } }
        }
    }

    common_should = []

    document_types.each do |search_type|
      search_klass = search_type.to_s.classify.constantize
      type_query = search_klass.allowed_to_search_query(User.current)
      common_should << type_query if type_query
    end

    payload = {
        query: {
            filtered: {
                query: {
                    bool: {
                        must: common_must,
                        must_not: common_must_not,
                        should: common_should,
                        minimum_should_match: 1
                    }
                }
            }
        },
        sort: [
            { datetime: { order: 'desc' } },
            :_score
        ],
        fields: ['_id'],
        facets: {
            types: {
                terms: {
                    field: '_type',
                    size: 10,
                    all_terms: false
                }
            }
        }
    }

    search_options = {
        page: options[:page].to_i,
        size: options[:size].to_i,
        from: (options[:page].to_i - 1) * options[:size].to_i,
        load: true,
        payload: payload
    }
    search = Tire.search RedmineElasticsearch::INDEX_NAME, search_options
    @query_curl ||= []
    @query_curl << search.to_curl
    search.results
  end

  def get_results_by_type_from_search_results(results)
    results_by_type = Hash.new { |h, k| h[k] = 0 }
    unless results.empty?
      results.facets['types']['terms'].each do |facet|
        results_by_type[facet['term']] = facet['count']
      end
    end
    results_by_type
  end
end

unless SearchController.included_modules.include?(RedmineElasticsearch::Patches::SearchControllerPatch)
  SearchController.send :include, RedmineElasticsearch::Patches::SearchControllerPatch
end
