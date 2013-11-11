class ChartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chart, only: [:show, :update, :destroy]

  def list
    @charts = current_user.charts.where("name IS NOT NULL").order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def share_chart
    # unless params[:id].blank? || params[:serialized_chart].blank?
    #   chart = current_user.charts.find(params[:id])
    #   chart.chart_json_serialized = params[:serialized_chart]
    #   chart.chart_title = params[:chart_title] unless params[:chart_title].blank?
    #   chart.chart_type = params[:chart_type] unless params[:chart_type].blank?
    #   chart.save(validate: false)
    # end
    render nothing: true
  end

  def update_chart_json_serialized
    unless params[:id].blank? || params[:serialized_chart].blank?
      chart = current_user.charts.find(params[:id])
      chart.chart_json_serialized = params[:serialized_chart]
      chart.chart_title = params[:chart_title] unless params[:chart_title].blank?
      chart.chart_type = params[:chart_type] unless params[:chart_type].blank?
      chart.save(validate: false)
    end
    render nothing: true
  end

  def index
    if params[:id].blank?
      @chart = Chart.new
      @chart.user_id = current_user.id
      @chart.group_by = 'any.host_id'
      @chart.name = nil
    else
      @chart = current_user.charts.find(params[:id])
    end
  end

  def show
    chart_search = Search.new
    @chart.copy_search_query_params_to_self
    chart_search.query_params = @chart.query_params
    if chart_search.query_params.blank?
      redirect_to charts_list_url, notice: "Unable to find selected search for this chart!"
      return
    end
    @total, @all_results = chart_search.perform_groupby(GroupExclude.host_ip_list(current_user)) unless @chart.blank?
  end

  def create
    @chart = Chart.new(chart_params)
    @chart.user_id = current_user.id
    if @chart.save
      redirect_to chart_path(id: @chart.id), notice: "Chart was created."
      return
    end
    render :index
  end

  def edit
  end

  def update
    @chart.chart_json_serialized = nil
    if @chart.update_attributes(chart_params)
      redirect_to chart_path(id: @chart.id), notice: "Chart was updated."
      return
    end
    render :index
  end

  def destroy
    @chart.destroy
    redirect_to charts_list_url, notice: "Deleted the chart named --> \"#{@chart.name}\"."
  end

  private

  # use callbacks to share common setup or constraints between actions.
  def set_chart
    @chart = current_user.charts.find(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def chart_params
    # remove single/double quotes from name which cause chart's to fail:
    params[:chart][:name] = params[:chart][:name].gsub(/'/, '').gsub(/"/, '') unless params[:chart][:name].blank?
    params[:chart][:chart_title] = params[:chart][:chart_title].gsub(/'/, '').gsub(/"/, '') unless params[:chart][:chart_title].blank?
    params.require(:chart).permit(
      :name, :chart_library, :chart_type, :chart_title, :group_by, :search_id
    )
  end
end
