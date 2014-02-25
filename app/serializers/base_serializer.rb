class BaseSerializer < ActiveModel::Serializer
  ROUTE_KEY = 'abc'
  self.root = false

  attributes :id, :route_key

  def route_key
    ROUTE_KEY
  end
end
