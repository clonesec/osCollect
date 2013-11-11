class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :only_admins, only: [:index, :new, :create, :destroy]
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_url, :notice => "User was successfully created."
    else
      render action: "new"
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      redirect_to users_url, notice: "User #{@user.username} was updated." and return if current_user.role?(:admin)
      redirect_to root_url,  notice: "Your profile was updated."
    else
      render action: "edit"
    end
  end

  def destroy
    if @user.username.strip.downcase == 'admin'
      flash[:error] = "Error: deleting the default admin account is not allowed!"
      redirect_to users_url
      return 
    end
    if @user.id == current_user.id
      flash[:error] = "Error: deleting your own account is not allowed!"
      redirect_to users_url
      return 
    end
    @user.destroy
    redirect_to users_url, notice: "User #{@user.username} was deleted."
  end

  private

  def only_admins
    redirect_to root_url, alert: 'Access denied!' unless current_user.role?(:admin)
  end

  # use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
      :username, :email, :password, :password_confirmation,
      :max_search_results, :search_results_page_size, :search_id
    )
  end
end
