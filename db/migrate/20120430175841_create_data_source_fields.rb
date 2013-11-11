class CreateDataSourceFields < ActiveRecord::Migration
  def change
    create_table :data_source_fields do |t|
      t.references  :data_source
      t.references  :data_field_type
      t.references  :data_pattern_type
      t.string      :name
      t.string      :solr_attr_name
      t.string      :input_validation
      t.integer     :position
      t.timestamps
    end
    add_index :data_source_fields, :data_source_id
    add_index :data_source_fields, :data_field_type_id
  end
end
