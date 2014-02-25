class ParentProjectSerializer < BaseSerializer
  attributes :is_public,
             :status,
             :enabled_module_names, :route_key

  def route_key
    ROUTE_KEY
  end
end
