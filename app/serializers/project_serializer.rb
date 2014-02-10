class ProjectSerializer < BaseSerializer
  attributes :name, :description,
             :homepage, :identifier,
             :created_on,
             :updated_on,
             :is_public
end
