module RedmineElasticsearch::SerializerExt::Event
  extend ActiveSupport::Concern

  included do
    attributes :event_date, :event_datetime, :event_title, :event_description,
               :event_author, :event_type, :event_url
  end

  def default_url_options
    { :host => Setting.host_name, :protocol => Setting.protocol }
  end

  def event_author
    object.event_author.to_s
  end

  def event_url
    url_for object.event_url(default_url_options)
  end

end
