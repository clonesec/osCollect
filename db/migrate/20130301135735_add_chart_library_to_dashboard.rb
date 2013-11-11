class AddChartLibraryToDashboard < ActiveRecord::Migration
  def change
    # all chart widgets must use the same library for a particular dashboard, i.e. no mixing
    add_column :dashboards, :chart_library, :string, default: 'gchart' # gchart, flotr2, ...
  end
end
