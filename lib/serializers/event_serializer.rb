class EventSerializer < ActiveModel::Serializer

  self.root = false

  attributes :id, :event_date, :event_datetime, :event_title, :event_description,
             :event_author, :event_type, :event_url

  def default_url_options
    { :host => Setting.host_name, :protocol => Setting.protocol }
  end

  def event_author
    object.author.to_s
  end

  def event_url
    url_for default_url_options.merge(object.event_url)
  end
end
