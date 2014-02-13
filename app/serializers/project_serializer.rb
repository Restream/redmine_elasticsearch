class ProjectSerializer < BaseSerializer
  attributes :name, :description,
             :homepage, :identifier,
             :created_on,
             :updated_on,
             :is_public,
             :custom_field_values

  def custom_field_values
    object.custom_field_values.map(&:to_s)
  end
end
