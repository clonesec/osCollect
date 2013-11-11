class AddChartLibraryToChart < ActiveRecord::Migration
  def change
    add_column :charts, :chart_library, :string, default: 'gchart' # gchart, flotr2, ...
  end
end
