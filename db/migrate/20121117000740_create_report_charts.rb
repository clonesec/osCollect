class CreateReportCharts < ActiveRecord::Migration
  def change
    create_table :report_charts do |t|
      t.references  :report
      t.references  :chart
      t.integer     :position
      t.timestamps
    end
    add_index :report_charts, :report_id
    add_index :report_charts, :chart_id
  end
end
