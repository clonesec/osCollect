class Report < ActiveRecord::Base
  belongs_to :user
  has_many :pdfs, dependent: :destroy
  has_many :report_histories, dependent: :destroy

  has_many :report_searches, inverse_of: :report, dependent: :destroy
  accepts_nested_attributes_for :report_searches, allow_destroy: true

  has_many :report_charts, inverse_of: :report, dependent: :destroy
  accepts_nested_attributes_for :report_charts, allow_destroy: true

  # attr_accessible :name, :description, :report_searches_attributes, :report_charts_attributes
  # attr_accessible :auto_run, :auto_run_at, :auto_run_daily_hour, :include_summary

  validates :name, presence: true
  validates :auto_run_at, presence: true # not necessary, as this is a select field with only 3 values
  validate :chart_or_search_was_selected
  
  before_save :set_auto_run

  def chart_or_search_was_selected
    # note: this will never work perfectly as Searches/Charts may be
    #       deleted independently of this Report, so there is no 
    #       choice but to ensure missing Searches/Charts are handled in views.
    no_charts = report_charts.all?(&:marked_for_destruction?)
    no_searches = report_searches.all?(&:marked_for_destruction?)
    errors.add(:base, 'Must select at least one Chart or Search') if no_charts && no_searches
  end

  def set_auto_run
    self.auto_run = ['Daily', 'Weekly'].include?(self.auto_run_at) ? true : false
    true # cls: for some reason returning "true" is required to avoid a validation error
  end

  def self.install_share(current_user_id, origin, report_hash)
    ActiveRecord::Base.transaction do
      report_attributes = report_hash.delete('report') # remove the root key 'report'
      # logger.debug "report_attributes(#{report_attributes.class})=#{report_attributes.to_yaml}\n#{'='*160}\n"
      report_charts_attributes = report_attributes.delete('report_charts_attributes')
      # logger.debug "report_charts_attributes(#{report_charts_attributes.class})=#{report_charts_attributes.to_yaml}\n#{'='*160}\n"
      report_searches_attributes = report_attributes.delete('report_searches_attributes')
      logger.debug "report_searches_attributes(#{report_searches_attributes.class})=#{report_searches_attributes.to_yaml}\n#{'='*160}\n"
      logger.debug "report_attributes(#{report_attributes.class})=#{report_attributes.to_yaml}\n#{'='*160}\n"
      report = self.new(report_attributes)
      report.user_id = current_user_id
      report.origin = origin
      report.save(validate: false)

      report_charts_attributes.each do |report_chart|
        logger.debug "report_chart(#{report_chart.class})=#{report_chart.inspect}\n#{'='*160}\n"
        chart_attrs = report_chart.delete('chart')
        chart = Chart.install_share(current_user_id, origin, chart_attrs)
        logger.debug "chart(#{chart.class})=#{chart.inspect}\n#{'='*160}\n"
        logger.debug "report_chart(#{report_chart.class})=#{report_chart.inspect}\n#{'='*160}\n"
        report_chart = ReportChart.install_share(report.id, chart.id, report_chart)
      end

      report_searches_attributes.each do |report_search|
        logger.debug "report_search(#{report_search.class})=#{report_search.inspect}\n#{'='*160}\n"
        search_attrs = report_search.delete('search')
        search = Search.install_share(current_user_id, origin, search_attrs)
        logger.debug "search(#{search.class})=#{search.inspect}\n#{'='*160}\n"
        logger.debug "report_search(#{report_search.class})=#{report_search.inspect}\n#{'='*160}\n"
        report_search = ReportSearch.install_share(report.id, search.id, report_search)
      end

      report
    end
  end

  def self.list_reports(user)
    reports = []
    user.reports.each do |d|
      reports << [d.name, d.id]
    end
    reports
  end
end
