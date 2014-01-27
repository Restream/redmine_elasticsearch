require 'active_support/concern'
require 'search_controller'

module RedmineElasticsearch::Patches::SearchControllerPatch
  extend ActiveSupport::Concern

  included do
    alias_method_chain :index, :elasticsearch
  end

  def index_with_elasticsearch
    @question = params[:q] || ''
    @question.strip!
    @all_words = params[:all_words] ? params[:all_words].present? : true
    @titles_only = params[:titles_only] ? params[:titles_only].present? : false

    # quick jump to an issue
    if issue = detect_issue_in_question(@question)
      redirect_to issue_path(issue)
      return
    end

    projects_to_search = get_projects_from_params
    @object_types = allowed_object_types(projects_to_search)
    @scope = filter_object_types_from_params(@object_types)

    @results = perform_search(
        :scope => @scope,
        :q => @question,
        :titles_only => @titles_only,
        :all_words => @all_words,
        :page => params[:page] || 1
    )
    @results_by_type = get_results_by_type_from_search_results(@results)

    render :layout => false if request.xhr?
  end

  private

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
      @object_types.delete('projects')
      # only show what the user is allowed to view
      @object_types = @object_types.select { |o| User.current.allowed_to?("view_#{o}".to_sym, projects_to_search) }
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
    search = Tire::Search::Search.new(index_names, :page => options[:page])
    search.query do |query|
      query.string options[:q]
    end
    search.facet('types') { terms :_type }
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
