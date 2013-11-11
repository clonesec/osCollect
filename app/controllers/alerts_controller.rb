class AlertsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_alert, only: [:history, :edit, :update, :destroy]

  def history
    @history = AlertHistory.where(alert_id: @alert.id).order(timestamp: :desc)
  end

  def index
    @alerts = current_user.alerts.order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
  end
  
  def new
    @alert = Alert.new
  end
  
  def create
    @alert = Alert.new(alert_params)
    @alert.user_id = current_user.id
    if @alert.save
      redirect_to alerts_url, :notice => "Alert \"#{@alert.name}\" was created."
    else
      render action: "new"
    end
  end
  
  def edit
  end
  
  def update
    if @alert.update_attributes(alert_params)
      redirect_to alerts_url, notice: "Alert \"#{@alert.name}\" was updated." and return
    else
      render action: "edit"
    end
  end
  
  def destroy
    @alert.destroy
    redirect_to alerts_url, notice: "Alert \"#{@alert.name}\" was deleted."
  end

  private

  # use callbacks to share common setup or constraints between actions.
  def set_alert
    unless params[:alert].blank?
      # remove single/double quotes from name to avoid display error:
      params[:alert][:name] = params[:alert][:name].gsub(/'/, '').gsub(/"/, '') unless params[:alert][:name].blank?
    end
    @alert = current_user.alerts.find(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def alert_params
    params.require(:alert).permit(
      :search_id, :active, :description, :last_run, :last_status_change, :name, :status,
      :threshold_count, :threshold_operator, :threshold_time_seconds, :logs_in_email,
      :history
    )
  end
end
