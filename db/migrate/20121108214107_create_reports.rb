class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.references  :user
      t.string      :name
      t.text        :description
      t.boolean     :auto_run, default: false
      t.datetime    :auto_run_last_at
      t.integer     :auto_run_count, default: 0
      t.string      :auto_run_at # null=RunNow/manual, Hourly, or Daily at :run_hour
      t.integer     :auto_run_daily_hour # 0..23 utc hours
      t.boolean     :include_summary, default: false
      t.timestamps
    end
    add_index :reports, :user_id
    add_index :reports, :auto_run
    add_index :reports, :auto_run_at
    add_index :reports, :auto_run_daily_hour
  end
end
