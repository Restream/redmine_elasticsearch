class NewsSerializer < BaseChildSerializer
  attributes :project_id,
             :title, :summary, :description,
             :created_on,
             :author,
             :comments_count

  def author
    object.author.try(:name)
  end
end
