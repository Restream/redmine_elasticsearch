class BaseChildSerializer < BaseSerializer
  attributes :_parent, :_routing, :route_key

  def route_key
    ROUTE_KEY
  end

  def _parent
    project_id
  end

  def _routing
    route_key
  end
end
