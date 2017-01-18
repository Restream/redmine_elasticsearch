class ChangesetSerializer < BaseSerializer
  attributes :project_id, :revision, :committer, :committed_on, :comments

  def project_id
    object.repository.try(:project_id)
  end
end
