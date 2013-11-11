class PasswordResetsController < ApplicationController
  before_action :set_user, only: [:edit, :update]

  layout 'sessions'

  def new
  end

  def show
    redirect_to root_path
  end

  def create
    user = User.find_by_email(params[:email])
    redirect_to new_password_reset_path, alert: "Invalid email!" and return unless user
    user.send_password_reset if user
    redirect_to login_url, :notice => "Email sent with password reset instructions."
  end

  def edit
  end

  def update
    if params[:user] && (params[:user][:password].blank? || params[:user][:password_confirmation].blank?)
      redirect_to edit_password_reset_url(params[:id]), alert: "Both passwords are required." and return
    end
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    elsif @user.update_attributes(user_params)
      redirect_to login_url, :notice => "Password has been reset!"
    else
      render :edit
    end
  end

  private

  # use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find_by_password_reset_token!(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
      :password, :password_confirmation
    )
  end
end
