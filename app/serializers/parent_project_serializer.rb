class ParentProjectSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id,
             :is_public,
             :status_id,
             :enabled_module_names, :route_key

  def route_key
    RedmineElasticsearch::IndexerService::ROUTE_KEY
  end

  def status_id
    object.status
  end
end
