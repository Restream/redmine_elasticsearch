module ProjectSearch
  extend ActiveSupport::Concern

  module ClassMethods

    def index_mappings
      {
          project: { properties: project_mappings_hash }
      }
    end

    def project_mappings_hash
      {
          id: { type: 'integer' },

          name: { type: 'string' },
          description: { type: 'string' },
          homepage: { type: 'string' },
          identifier: { type: 'string' },

          created_on: { type: 'date' },
          updated_on: { type: 'date' },

          is_public: { type: 'boolean' },

          custom_field_values: { type: 'string', index_name: 'cfv' }

      }.merge(additional_index_mappings)
    end

    def searching_scope
      self.active
    end
  end
end
