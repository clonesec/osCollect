class Widget < ActiveRecord::Base
  belongs_to :dashboard
  belongs_to :chart

  acts_as_list scope: :dashboard

  # attr_accessible :position, :chart_id

  def self.install_share(dashboard_id, chart_id, widget_hash)
    widget = self.new(widget_hash)
    widget.dashboard_id = dashboard_id
    widget.chart_id = chart_id
    widget.save(validate: false)
    widget
  end
end
