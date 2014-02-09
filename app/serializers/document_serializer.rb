class DocumentSerializer < BaseSerializer
  attributes :project_id,
             :title, :description,
             :created_on,
             :category

  def category
    object.category.try(:name)
  end
end
