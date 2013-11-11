class CreateDataFieldTypes < ActiveRecord::Migration
  def change
    create_table :data_field_types do |t|
      # enum('string', 'int')
      t.string      :field_type
      t.timestamps
    end
  end
end
