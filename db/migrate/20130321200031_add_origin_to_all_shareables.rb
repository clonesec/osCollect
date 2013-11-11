class AddOriginToAllShareables < ActiveRecord::Migration
  def change
    add_column :searches,     :origin, :string, default: nil
    add_column :alerts,       :origin, :string, default: nil
    add_column :charts,       :origin, :string, default: nil
    add_column :reports,      :origin, :string, default: nil
    add_column :dashboards,   :origin, :string, default: nil
  end
end
