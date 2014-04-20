class DocumentSerializer < BaseSerializer
  attributes :project_id,
             :title, :description,
             :created_on,
             :category

  has_many :attachments, :serializer => AttachmentSerializer

  def category
    object.category.try(:name)
  end
end
