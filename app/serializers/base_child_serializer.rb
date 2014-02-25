class BaseChildSerializer < BaseSerializer
  attributes :_parent, :_routing

  def _parent
    project_id
  end

  def _routing
    ROUTE_KEY
  end
end
