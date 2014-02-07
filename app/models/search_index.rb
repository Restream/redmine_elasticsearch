class SearchIndex < ActiveRecord::Base

  validates :search_type, :presence => true, :uniqueness => true

  serialize :schema, Hash

end
