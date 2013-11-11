class RemoveChartLibraryFromDashboard < ActiveRecord::Migration
  def change
    remove_column :dashboards, :chart_library
  end
end
