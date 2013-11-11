class AdminRestriction
  # note: this is called for every request to the Resque web server:
  def matches?(request)
    # note: when this method returns "false" rails shows a bad route error, instead of access denied.
    # Nov 2013: in Rails 4 this doesn't work coz it's nil:
    # auth_token = request.env['rack.request.cookie_hash']['auth_token']
    return false unless (auth_token_cookie = request.cookies['auth_token'])
    user = User.find_by(auth_token: auth_token_cookie)
    # puts "\n#{Time.now.utc}"
    # puts "auth_token_cookie=#{auth_token_cookie.inspect}"
    # puts "user && user.role?(:admin)=#{(user && user.role?(:admin)).inspect}\nuser=#{user.inspect}"
    # puts "user=#{user.inspect}"
    user && user.role?(:admin)
  end
end

OsCollect::Application.routes.draw do
  mount Resque::Server => '/resque', :constraints => AdminRestriction.new

  resources :sessions
  get "login" => "sessions#new", :as => "login"
  get "logout" => "sessions#destroy", :as => "logout"

  resources :password_resets

  resources :users
  resources :groups

  resources :hosts

  resources :logs
  get "log_metrics" => "logs#log_metrics", :as => "log_metrics"
  get "logs_by_date" => "logs#logs_by_date", :as => "logs_by_date"
  get "srcips" => "logs#srcips", :as => "srcips"
  get "dstips" => "logs#dstips", :as => "dstips"

  resources :shares
  get "install_share/:id" => "shares#install_share", :as => "install_share"

  resources :charts
  get "charts_list" => "charts#list", :as => "charts_list"
  post "update_chart_json_serialized/:id" => "charts#update_chart_json_serialized", :as => "update_chart_json_serialized"
  post "share_chart/:id" => "charts#share_chart", :as => "share_chart"

  resources :dashboards
  post "update_widget_order/:id" => "dashboards#update_widget_order", :as => "update_widget_order"
  # get "dbprintable/:id/:user_id" => "dashboards#dbprintable", :as => "dbprintable"
  # get "preview" => "dashboards#preview", :as => "preview"

  resources :reports
  get "printable/:id/:user_id/:type" => "reports#printable", :as => "printable"
  get "reports_history/:id" => "reports#history", :as => "reports_history"

  resources :pdfs

  resources :alerts
  get "alerts_history/:id" => "alerts#history", :as => "alerts_history"

  resources :searches
  get "data_fields" => "searches#get_fields_for_datasource", :as => "data_fields"
  get "searches_list" => "searches#list", :as => "searches_list"
  get "home" => "searches#index", :as => "home"
  root :to => "searches#index"
end
