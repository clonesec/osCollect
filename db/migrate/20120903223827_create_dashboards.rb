class CreateDashboards < ActiveRecord::Migration
  def change
    create_table :dashboards do |t|
      t.references  :user
      t.string      :name
      t.timestamps
    end
    add_index :dashboards, :user_id
  end
end
