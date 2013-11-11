class AddSendWeeklyLogCountsToUser < ActiveRecord::Migration
  def change
    add_column :users, :send_weekly_log_counts, :boolean, default: false
  end
end
