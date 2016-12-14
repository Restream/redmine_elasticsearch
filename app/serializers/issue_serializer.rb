class IssueSerializer < BaseSerializer
  attributes :project_id,
             :subject, :description,
             :created_on, :updated_on, :closed_on,
             :author,
             :author_id,
             :assigned_to,
             :assigned_to_id,
             :category,
             :status,
             :done_ratio,
             :custom_field_values,
             :private,
             :priority,
             :fixed_version,
             :due_date,
             :closed

  has_many :journals, serializer: JournalSerializer
  has_many :attachments, serializer: AttachmentSerializer

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

  def custom_field_values
    fields = object.custom_field_values.find_all { |cfv| cfv.custom_field.searchable? }
    fields.map(&:to_s)
  end

  def closed_on
    Redmine::VERSION.to_s >= '2.3.0' ? object.closed_on : nil
  end

  def priority
    object.priority.try(:name)
  end

  def fixed_version
    object.fixed_version.try(:name)
  end

  def private
    object.is_private?
  end

  def closed
    object.closed?
  end
end
