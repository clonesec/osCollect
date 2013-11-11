class HostsController < ApplicationController
  before_action :authenticate_user!
  # before_action :only_allow_admins
  before_action :deprecated_nov_2013

  def index
    @hosts = Host.order(host_ip: :asc).page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    @ip = params[:id]
    @type = params[:type]
    valid_type = ['daily', 'weekly', 'outage'].include?(@type)
    redirect_to hosts_url, notice: 'Only daily and weekly histories are available.' unless valid_type
    @host = Host.find_by_host_ip @ip
    redirect_to hosts_url, notice: 'Host not found.' if @host.blank?
    if @type == 'weekly'
      @history = HostHistory.where(host_ip: @ip).where("history_type = 'weekly'").where('count > 0').order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
    elsif @type == 'daily'
      @history = HostHistory.where(host_ip: @ip).where("history_type = 'daily'").where('count > 0').order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
    else
      @history = HostHistory.where(host_ip: @ip).where('count = 0').order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
    end
  end

  def new
    @host = Host.new
  end

  def create
    @host = Host.new(params[:host])
    if @host.save
      redirect_to hosts_url, notice: 'Host was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @host = Host.find(params[:id])
  end

  def update
    @host = Host.find(params[:id])
    if @host.update_attributes(params[:host])
      redirect_to hosts_url, notice: 'Host was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @host = Host.find(params[:id])
    @host.destroy
    redirect_to hosts_url
  end

  private

  def deprecated_nov_2013
    redirect_to root_url, alert: "Access denied!"
  end

  def only_allow_admins
    # raise CanCan::AccessDenied unless current_user.role? :admin
  end
end