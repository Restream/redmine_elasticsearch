class DocumentSerializer < BaseSerializer
  attributes :project_id,
             :title, :description,
             :created_on,
             :category

  has_many :attachments, :serializer => AttachmentSerializer

  def category
    object.category.try(:name)
  end

  def attachments
    object.attachments.find_all { |attachment| AttachmentSerializer.supported?(attachment) }
  end
end
