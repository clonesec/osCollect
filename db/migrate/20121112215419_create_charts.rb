class CreateCharts < ActiveRecord::Migration
  def change
    create_table :charts do |t|
      t.references  :user
      t.references  :search
      t.string      :name
      t.string      :chart_type
      t.string      :chart_title
      t.text        :chart_json_serialized
      t.integer     :group_by
      t.text        :sentinel_params
      t.timestamps
    end
    add_index :charts, :user_id
    add_index :charts, :search_id
  end
end
