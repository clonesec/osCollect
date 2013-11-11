class LogsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :authenticate_user!
  before_action :set_log, only: [:show, :edit, :update, :destroy]

  def index
    @logs = current_user.logs.order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def new
    @log = Log.new
  end
  
  def create
    @log = Log.new(log_params)
    @log.user_id = current_user.id
    if @log.save
      redirect_to logs_url, :notice => "Log Counts Watcher \"#{@log.name}\" was created."
    else
      render action: "new"
    end
  end
  
  def edit
  end
  
  def update
    if @log.update_attributes(log_params)
      redirect_to logs_url, notice: "Log Counts Watcher \"#{@log.name}\" was updated." and return
    else
      render action: "edit"
    end
  end

  def srcips
    @error_message = nil
    @total, @counts = Search.facet_counts('srcip_t')
  end

  def dstips
    @error_message = nil
    @total, @counts = Search.facet_counts('dstip_t')
  end

  def logs_by_date
    @error_message = nil
    @date_total, @date_counts = Search.counts_by_date
  end

  def log_metrics
    @error_message = nil
    @total, @host_counts = Search.host_counts(GroupExclude.host_ip_list(current_user))
  end

  def destroy
    @log.destroy
    redirect_to logs_url
  end

  private

  # use callbacks to share common setup or constraints between actions.
  def set_log
    @log = current_user.logs.find(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def log_params
    # remove single/double quotes from name to avoid display error:
    params[:log][:name] = params[:log][:name].gsub(/'/, '').gsub(/"/, '') unless params[:log][:name].blank?
    params[:log][:host_ips] = params[:log][:host_ips].gsub(/\r\n\t?/, ' ').gsub(/\s+/, ' ').strip unless params[:log][:host_ips].blank?
    params.require(:log).permit(
      :active, :name, :description, :host_ips, :auto_run_at, :last_run, :send_email
    )
  end
end
