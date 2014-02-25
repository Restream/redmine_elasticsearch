class ParentProjectSerializer < BaseSerializer
  attributes :is_public,
             :status,
             :enabled_module_names
end
