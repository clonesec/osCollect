class CreateShare < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.references  :user
      t.string      :share_token
      t.integer     :shared_id
      t.string      :share_type
    end
    add_index :shares, :share_token
    add_index :shares, :user_id
  end
end
