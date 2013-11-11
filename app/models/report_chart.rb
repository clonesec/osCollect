class ReportChart < ActiveRecord::Base
  belongs_to :report, inverse_of: :report_charts
  acts_as_list scope: :report
  belongs_to :chart
  # attr_accessible :position, :chart_id

  def self.install_share(report_id, chart_id, report_chart_hash)
    report_chart = self.new(report_chart_hash)
    report_chart.report_id = report_id
    report_chart.chart_id = chart_id
    report_chart.save(validate: false)
    report_chart
  end
end
