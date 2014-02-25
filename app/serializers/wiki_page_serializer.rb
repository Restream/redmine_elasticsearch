class WikiPageSerializer < BaseChildSerializer
  attributes :project_id,
             :title, :text,
             :created_on, :updated_on

  def project_id
    object.wiki.try(:project_id)
  end
end
