class CreateSearchIndices < ActiveRecord::Migration
  def change
    create_table :search_indices do |t|
      t.string :search_type, :null => false
      t.text :schema
      t.timestamps
    end

    add_index :search_indices, :search_type, :unique => true
  end
end
