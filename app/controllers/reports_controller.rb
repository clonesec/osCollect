class ReportsController < ApplicationController
  before_action :authenticate_user!, except: [:printable]
  before_action :check_reports_path
  before_action :get_charts_for_select, except: [:index, :show, :destroy, :printable]
  before_action :get_searches_for_select, except: [:index, :show, :destroy, :printable]
  before_action :set_hours_for_daily_select, except: [:index, :show, :destroy, :printable]
  before_action :set_report, only: [:history, :edit, :update, :destroy]

  def printable
    # cls: test using: /Users/cleesmith/Sites/osCollect/lib/phantomjs/phantomjs /Users/cleesmith/Sites/osCollect/lib/phantomjs/rasterize.js http://localhost:3000/printable/1/1/Daily "/Users/cleesmith/Sites/osCollect/shared/reports/1/cls.pdf" "Letter" 10000
    #      or: http://localhost:3000/printable/1/1/Daily
    Rails.logger.info "->->-> ReportsController:printable - request from: #{request.remote_ip} | #{request.ip}"
    # WARNING: this is not very secure, but this app isn't world-facing so maybe limiting print 
    #          only requests from the local IP will be ok:
    unless request.remote_ip == APP_CONFIG[:reports_allowed_ip] && request.ip == APP_CONFIG[:reports_allowed_ip]
      render text: "Access denied! #{request.remote_ip} #{request.ip}", status: 500
      return
    end
    # note: looping/waiting for multiple charts/searches may take a long time, so
    #       be sure to adjust the "setTimeout" in rasterize.js according
    current_user = User.find(params[:user_id])
    @report = current_user.reports.find(params[:id])
    @report_type = params[:type].blank? ? 'RunNow' : params[:type]
    @report_time = Time.now.utc
    case @report_type
    when 'Daily' # set start/end to yesterday
      time_range_altered = true
      @start_time = (@report_time - 1.day).beginning_of_day
      @end_time = (@report_time - 1.day).end_of_day
    when 'Weekly' # set start/end to last week
      time_range_altered = true
      @start_time = (@report_time - 1.week).beginning_of_week(start_day = :sunday)
      @end_time = (@report_time - 1.week).end_of_week(start_day = :sunday)
    else
      time_range_altered = false
    end
    @charts = []
    @report.report_charts.order(position: :asc).each do |chart_section|
      section_chart = chart_section.chart unless chart_section.chart_id.blank?
      if section_chart
        chart = section_chart
        chart_search = Search.new
        chart_search.query_params = section_chart.query_params
        if time_range_altered
          # override the from_timestamp/to_timestamp in query_params:
          chart_search.query_params['from_timestamp'] = @start_time.utc.iso8601
          chart_search.query_params['to_timestamp'] = @end_time.utc.iso8601
        end
        chart.total, chart.results = chart_search.perform_groupby(GroupExclude.host_ip_list(current_user)) unless chart_search.blank?
        @charts << chart
      end 
    end
    @searches = []
    @report.report_searches.order(position: :asc).each do |search_section|
      search = search_section
      if time_range_altered
        # override the from_timestamp/to_timestamp in query_params:
        search_section.search.query_params['from_timestamp'] = @start_time.utc.iso8601
        search_section.search.query_params['to_timestamp'] = @end_time.utc.iso8601
      end
      # search.results = search_section.search.perform(GroupNode.allowed_list(current_user), GroupExclude.host_ip_list(current_user)) unless search_section.search.blank?
      search.results = search_section.search.perform(GroupExclude.host_ip_list(current_user)) unless search_section.search.blank?
      @searches << search
    end
    render layout: 'printable'
  end

  def history
    @history = ReportHistory.where(report_id: @report.id).order(timestamp: :desc)
  end

  def index
    @reports = current_user.reports.order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    redirect_to reports_url, notice: 'Access denied.'
  end

  def new
    @report = Report.new
    @report.auto_run_at = 'Never' if @report.auto_run_at.blank?
  end

  def create
    @report = Report.new(report_params)
    @report.user_id = current_user.id
    if @report.save
      redirect_to reports_url, notice: 'Report was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @report.auto_run_at = 'Never' if @report.auto_run_at.blank? # cls: compensate for db values
  end

  def update
    if @report.update_attributes(report_params)
      redirect_to reports_url, notice: 'Report was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @report.pdfs.each do |pdf|
      file = pdf.path_to_file + '/' + pdf.file_name
      begin
        FileUtils.rm(file) if File.exist?(file)
      rescue Errno::ENOENT => e
        # ignore file not found, so can't delete what's not there
      end
    end
    @report.destroy
    redirect_to reports_url
  end

  private

  # use callbacks to share common setup or constraints between actions.
  def set_report
    @report = current_user.reports.find(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def report_params
    # remove single/double quotes from name to avoid display error:
    params[:report][:name] = params[:report][:name].gsub(/'/, '').gsub(/"/, '') unless params[:report][:name].blank?
    # Nov 2013: these aren't sent as params anymore:
    # :auto_run, :auto_run_daily_hour, :include_summary
    params.require(:report).permit(
      :name, :auto_run_at, :description,
      report_charts_attributes: [:id, :_destroy, :chart_id],
      report_searches_attributes: [:id, :_destroy, :search_id]
    )
  end

  def get_charts_for_select
    charts = current_user.charts.order(updated_at: :desc)
    @charts = []
    charts.each do |c|
      @charts = @charts << ['title: ' + c.chart_title + '  -- ' + c.name, c.id]
    end
    @charts
  end

  def get_searches_for_select
    @searches = Search.list_saved_searches(current_user)
  end

  def set_hours_for_daily_select
    @hours = [
      ['00 - midnight', 0],
      ['01 -  1am', 1],
      ['02 -  2am', 2],
      ['03 -  3am', 3],
      ['04 -  4am', 4],
      ['05 -  5am', 5],
      ['06 -  6am', 6],
      ['07 -  7am', 7],
      ['08 -  8am', 8],
      ['09 -  9am', 9],
      ['10 - 10am', 10],
      ['11 - 11am', 11],
      ['12 - noon', 12],
      ['13 -  1pm', 13],
      ['14 -  2pm', 14],
      ['15 -  3pm', 15],
      ['16 -  4pm', 16],
      ['17 -  5pm', 17],
      ['18 -  6pm', 18],
      ['19 -  7pm', 19],
      ['20 -  8pm', 20],
      ['21 -  9pm', 21],
      ['22 - 10pm', 22],
      ['23 - 11pm', 23]
    ]
  end

  def check_reports_path
    if Rails.env.production? && APP_CONFIG[:reports_path].include?(Rails.root.to_s)
      redirect_to root_url, alert: "Reports/PDFs are unavailable, because the reports path is within this application's folder. Please contact a system administrator."
    end
  end
end
