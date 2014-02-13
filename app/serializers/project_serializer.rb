class ProjectSerializer < BaseSerializer
  attributes :name, :description,
             :homepage, :identifier,
             :created_on,
             :updated_on,
             :is_public,
             :custom_field_values

  def custom_field_values
    fields = object.custom_field_values.find_all { |cfv| cfv.custom_field.searchable? }
    fields.map(&:to_s)
  end
end
