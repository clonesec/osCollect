class CreateGroupExcludes < ActiveRecord::Migration
  def change
    create_table :group_excludes do |t|
      t.references  :group
      t.string      :ip_range_from
      t.integer     :ip_range_from_num
      t.string      :ip_range_to
      t.integer     :ip_range_to_num
      t.timestamps
    end
    add_index :group_excludes, :group_id
  end
end
