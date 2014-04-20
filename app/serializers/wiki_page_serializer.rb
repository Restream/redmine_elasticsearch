class WikiPageSerializer < BaseSerializer
  attributes :project_id,
             :title, :text,
             :created_on, :updated_on

  has_many :attachments, :serializer => AttachmentSerializer

  def project_id
    object.wiki.try(:project_id)
  end

  def author
    nil
  end

  def attachments
    object.attachments.find_all { |attachment| AttachmentSerializer.supported?(attachment) }
  end
end
