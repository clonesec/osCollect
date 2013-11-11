class DashboardsController < ApplicationController
  before_filter :authenticate_user!, except: [:printable]
  before_filter :get_charts_for_select, except: [:printable]
  before_action :set_dashboard, only: [:show, :edit, :update, :destroy]

  def update_widget_order
    dashboard_id = params[:id]
    reordered_widgets = JSON.parse(params[:widgets])
    unless dashboard_id.blank? || reordered_widgets.blank? || reordered_widgets.empty?
      reordered_widgets.each_with_index do |id, index|
        Widget.update(id, position: index+1)
      end
    end
    # rearranging widgets is not critical so return nothing:
    render nothing: true
  end

  def index
    @dashboards = current_user.dashboards.order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    @charts = []
    @dashboard.widgets.order(position: :asc).each do |widget|
      next if widget.chart.blank?
      widget_chart = widget.chart
      if widget_chart.search
        chart = widget_chart
        chart_search = Search.new
        # always copy the query_params from this chart's search reference,
        # as this will set query_params properly based on the search and the selected groupby:
        widget_chart.copy_search_query_params_to_self
        chart_search.query_params = widget_chart.query_params
        if chart_search.query_params.blank?
          chart.results = nil
        else
          @total, @all_results = chart_search.perform_groupby(GroupExclude.host_ip_list(current_user)) unless chart_search.blank?
        end
        chart.widget_id = widget.id
        @charts << chart
      end 
    end
    render layout: 'dashboards'
  end

  def new
    @dashboard = Dashboard.new
  end

  def create
    @dashboard = Dashboard.new(dashboard_params)
    @dashboard.user_id = current_user.id
    if @dashboard.save
      redirect_to dashboards_url, notice: 'Dashboard was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
  end

  def update
    if @dashboard.update_attributes(dashboard_params)
      redirect_to dashboards_url, notice: 'Dashboard was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @dashboard.destroy
    redirect_to dashboards_url
  end

  private

  def get_charts_for_select
    charts = current_user.charts.where("name IS NOT NULL").order(updated_at: :desc)
    @charts = []
    charts.each do |c|
      @charts = @charts << ['title: ' + c.chart_title + '  -- ' + c.name, c.id]
    end
    @charts
  end

  # use callbacks to share common setup or constraints between actions.
  def set_dashboard
    @dashboard = current_user.dashboards.find(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def dashboard_params
    # remove single/double quotes from name which cause chart's to fail:
    params[:dashboard][:name] = params[:dashboard][:name].gsub(/'/, '').gsub(/"/, '') unless params[:dashboard][:name].blank?
    params.require(:dashboard).permit(
      :name,
      widgets_attributes: [:id, :_destroy, :chart_id]
    )
  end
end
