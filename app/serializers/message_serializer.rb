class MessageSerializer < BaseChildSerializer
  attributes :project_id,
             :subject, :content,
             :author,
             :created_on,
             :updated_on,
             :replies_count

  def project_id
    object.board.try(:project_id)
  end

  def author
    object.author.try(:name)
  end
end
