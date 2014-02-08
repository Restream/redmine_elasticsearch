class IssueSerializer < BaseSerializer
  attributes :project_id,
             :subject, :description,
             :created_on, :updated_on, :closed_on,
             :author,
             :assigned_to,
             :category,
             :status,
             :done_ratio

  has_many :journals, :serializer => JournalSerializer

  def author
    object.author.try(:name)
  end

  def assigned_to
    object.assigned_to.try(:name)
  end

  def category
    object.category.try(:name)
  end

  def status
    object.status.try(:name)
  end
end
