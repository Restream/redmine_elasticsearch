class BaseSerializer < ActiveModel::Serializer
  ROUTE_KEY = 'abc'
  self.root = false

  attributes :id
end
