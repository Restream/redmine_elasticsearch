class ParentProjectSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id,
             :is_public,
             :status_id,
             :enabled_module_names

  def status_id
    object.status
  end
end
