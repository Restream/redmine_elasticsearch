class BaseSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :_parent, :datetime, :title, :description, :author, :url, :type

  def _parent
    project_id if respond_to? :project_id
  end

  %w(datetime title description).each do |attr|
    class_eval "def #{attr}() object.event_#{attr} end"
  end

  def type
    object.class.document_type
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
    { host: Setting.host_name, protocol: Setting.protocol }
  end
end
