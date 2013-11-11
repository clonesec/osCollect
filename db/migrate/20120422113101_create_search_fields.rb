class CreateSearchFields < ActiveRecord::Migration
  def change
    create_table :search_fields do |t|
      t.references  :search
      t.references  :data_source
      t.references  :data_source_field
      t.references  :data_field_operator
      t.string      :and_or
      t.text        :match_or_attribute_value
      t.timestamps
    end
    add_index :search_fields, :search_id
    add_index :search_fields, :data_source_id
    add_index :search_fields, :data_source_field_id
    add_index :search_fields, :data_field_operator_id
  end
end
