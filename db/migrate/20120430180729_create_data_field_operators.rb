class CreateDataFieldOperators < ActiveRecord::Migration
  def change
    create_table :data_field_operators do |t|
      t.string      :operator
      t.timestamps
    end
  end
end
