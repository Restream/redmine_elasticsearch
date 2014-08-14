class BaseSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :_parent, :_routing, :route_key,
             :datetime, :title, :description, :author, :url, :type

  def route_key
    RedmineElasticsearch::IndexerService::ROUTE_KEY
  end

  def _parent
    object.project_id if object.respond_to? :project_id
  end

  def _routing
    route_key
  end

  %w(datetime title description).each do |attr|
    class_eval "def #{attr}() object.event_#{attr} end"
  end

  def type
    object.class.index_document_type
  end

  def author
    object.event_author && object.event_author.to_s
  end

  def url
    url_for object.event_url(default_url_options)
  rescue
    nil
  end

  def default_url_options
    { :host => Setting.host_name, :protocol => Setting.protocol }
  end
end
