class CreateHostHistories < ActiveRecord::Migration
  def change
    create_table :host_histories do |t|
      t.string      :history_type, default: 'weekly'  # weekly or daily
      t.integer     :host_ip, limit: 8
      t.string      :host
      # note: 0(zero) indicates this host sent no logs during this time period (start/end_time):
      t.integer     :count, limit: 8, default: 0
      t.integer     :year
      t.integer     :week
      t.datetime    :start_time
      t.datetime    :end_time
      t.timestamps
    end
    add_index :host_histories, :host_ip
    add_index :host_histories, [:year, :week]
    add_index :host_histories, :history_type
  end
end
