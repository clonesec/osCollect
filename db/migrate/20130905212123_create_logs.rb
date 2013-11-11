class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.references  :user
      t.boolean     :active, default: true
      t.string      :name
      t.text        :description
      t.text        :host_ips
      t.string      :auto_run_at, default: 'both'
      t.integer     :last_run, default: 0
      t.timestamps
    end
    add_index :logs, :user_id
  end
end
