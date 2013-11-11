class SessionsController < ApplicationController
  layout 'sessions'

  def new
  end

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      unless user.search_id.blank?
        # ensure user is allowed to access this dashboard,
        # i.e. an admin may set an invalid dashboard for a user:
        dashboard = user.dashboards.where(id: user.search_id)
        unless dashboard.blank?
          redirect_to dashboard_path(id: user.search_id)
          return
        end
      end
      redirect_to (session[:ref] || root_url)
    else
      flash.now.alert = "Invalid username or password"
      render "new"
    end
  end

  def destroy
    session[:ref] = nil
    cookies.delete(:auth_token)
    redirect_to login_url
  end
end
