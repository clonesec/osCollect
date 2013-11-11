class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.references  :user
      t.references  :search
      t.boolean     :active, default: true
      t.boolean     :logs_in_email, default: true
      t.string      :status, default: 'n'
      t.integer     :last_run, default: 0
      t.integer     :last_total_matches, default: 0
      t.integer     :last_status_change, default: 0
      t.string      :name
      t.text        :description
      t.string      :threshold_operator, default: 'gt'
      t.integer     :threshold_count, default: 0
      t.integer     :threshold_time_seconds, default: 0
      t.timestamps
    end
    add_index :alerts, :user_id
    add_index :alerts, :search_id
  end
end
