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
      @results = perform_search(
          :scope => @scope,
          :q => @question,
          :titles_only => @titles_only,
          :all_words => @all_words,
          :page => params[:page] || 1,
          :size => RESULT_SIZE,
          :projects => @projects_to_search
      )
      @results_by_type = get_results_by_type_from_search_results(@results)
      render :layout => false if request.xhr?
    end
  rescue Tire::Search::SearchRequestFailed => e
    logger.error e
    render_error :message => :search_request_failed, :status => 503
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
    return [] if options[:q].blank?
    index_names = tire_index_names(options[:scope])
    search_options = {
        :page => options[:page].to_i,
        :size => options[:size].to_i,
        :from => (options[:page].to_i - 1) * options[:size].to_i,
        :load => true
    }
    project_ids = options[:projects] ? [options[:projects]].flatten.compact.map(&:id) : nil
    queries_by_object_types = []
    @object_types.each do |search_type|
      search_klass = search_type.to_s.classify.constantize
      document_type = search_klass.index.get_type_from_document(search_klass)
      queries_by_object_types << if search_klass.respond_to?(:allowed_to_search_query)
        q = search_klass.allowed_to_search_query(User.current,
                                                 :project_ids => project_ids)
        "_type:#{document_type} AND (#{q})"
      else
        "_type:#{document_type}"
      end
    end
    search = Tire::Search::Search.new(index_names, search_options) do
      query do
        filtered do
          query do
            boolean(minimum_should_match: 1) do
              must { string options[:q] }
              queries_by_object_types.each do |filter_by_object_type|
                should { string filter_by_object_type }
              end
            end
          end
        end
      end
      facet('types') { terms :_type }
    end
    @query_curl = search.to_curl
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

  def tire_index_names(object_types)
    object_types.map { |object_type| object_type.classify.constantize.index_name }
  end
end

unless SearchController.included_modules.include?(RedmineElasticsearch::Patches::SearchControllerPatch)
  SearchController.send :include, RedmineElasticsearch::Patches::SearchControllerPatch
end
