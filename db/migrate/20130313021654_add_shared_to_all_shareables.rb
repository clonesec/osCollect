class AddSharedToAllShareables < ActiveRecord::Migration
  def change
    add_column :searches,     :shared, :string, default: nil
    add_column :alerts,       :shared, :string, default: nil
    add_column :charts,       :shared, :string, default: nil
    add_column :reports,      :shared, :string, default: nil
    add_column :dashboards,   :shared, :string, default: nil
  end
end
