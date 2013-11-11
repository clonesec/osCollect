class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.references  :user
      t.references  :search_type, default: 1 # 1=search, 2=logcaster
      t.string      :name
      t.text        :query
      t.text        :sources
      t.string      :relative_timestamp
      t.string      :date_from
      t.string      :time_from
      t.string      :date_to
      t.string      :time_to
      t.string      :host_from
      t.string      :host_to
      t.integer     :group_by
      t.text        :sentinel_params
      t.timestamps
    end
    add_index :searches, :user_id
  end
end
