class SharesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :is_sharing_allowed

  # rescue_from CanCan::NotImplemented do |exception|
  #   flash[:error] = "Sharing is not configured properly, please contact an administrator."
  #   redirect_to root_url
  # end

  def list
    # list my shares: user can unshare
    redirect_to shares_path
  end

  def install_share
    share_token = params[:id]
    response = Typhoeus::Request.get("#{Share.url}/#{share_token}", headers: Share.header)
    error = nil
    if response.success?
    elsif response.code == 0
      # no http response:
      error = "Error: " + response.return_code.to_s
    elsif response.timed_out?
      error = "Error: Time out:\n" + response.code.to_s
    else
      # non-successful http response:
      error = "Error: HTTP request failed:\n" + response.code.to_s
    end
    error = error + response.body unless error.blank?
    share_as_hash = JSON.parse(response.body) if error.blank?
    if error.blank?
      install_share_based_on_type(share_token, share_as_hash)
    else
      redirect_to shares_path, notice: error
    end
  end

  def index
    # list shares available for installation, without user's shares
    # cls: somehow do pagination:
    # @nodes = Node.order(name: :asc).page(params[:page]).per_page(APP_CONFIG[:per_page])
    response = Typhoeus::Request.get(Share.url, headers: Share.header)
    @error = nil
    if response.success?
    elsif response.code == 0
      # no http response:
      @error = "Error: " + response.return_code.to_s
    elsif response.timed_out?
      @error = "Error: Time out:\n" + response.code.to_s
    else
      # non-successful http response:
      @error = "Error: HTTP request failed:\n" + response.code.to_s
    end
    # @error = @error + response.body unless @error.blank?
    @shares = @error.blank? ? JSON.parse(response.body) : nil
  end

  def show
    redirect_to shares_path
  end

  def new
    redirect_to shares_path
  end

  def create
    id = params[:id]
    type = params[:type]
    # FIXME put object details in description:
    desc = ""
    notice_message = "#{type} was shared."
    share_response = nil
    case type
    when 'Search'
      shared_object = Search.find(id)
      share_as_json = SearchSerializer.new(shared_object).to_json
    when 'Alert'
      shared_object = Alert.find(id)
      share_as_json = AlertSerializer.new(shared_object).to_json
    when 'Chart'
      shared_object = Chart.find(id)
      share_as_json = ChartSerializer.new(shared_object).to_json
    when 'Report'
      shared_object = Report.find(id)
      share_as_json = ReportSerializer.new(shared_object).to_json
    when 'Dashboard'
      shared_object = Dashboard.find(id)
      share_as_json = DashboardSerializer.new(shared_object).to_json
    end
    share_response = send_share(current_user, request.host_with_port, type, shared_object.name, desc, share_as_json)
    if share_response.blank? || share_response['token'].blank?
      share_response = share_response.blank? ? '' : share_response
      notice_message = "Unable to share #{type}.\n" + share_response
    else
      ActiveRecord::Base.transaction do
        user_share = Share.new
        user_share.user_id = current_user.id
        user_share.share_token = share_response['token']
        user_share.shared_id = id
        user_share.share_type = type
        user_share.save!
        shared_object.shared = share_response['token']
        shared_object.user_id = current_user.id
        shared_object.save!
      end
    end
    # note: view_context.raw() allows us to use html in the notice:
    redirect_to shares_path, notice: view_context.raw(notice_message)
  end

  def edit
    redirect_to shares_path
  end

  def update
    redirect_to shares_path
  end

  def destroy
    share_token = params[:share_token]
    # for rails, a DELETE request (destroy action) is the "url/id" 
    # plus a "_method" field set to 'delete' in the body:
    response = Typhoeus::Request.post("#{Share.url}/#{share_token}", headers: Share.header, body: {_method: 'delete'})
    err = nil
    if response.success?
    elsif response.code == 422
      err = response.code.to_s + ': ' + JSON.parse(response.body)['errors']
    elsif response.code == 0
      err = response.return_code.to_s
    elsif response.timed_out?
      err = "Time out: " + response.code.to_s
    else
      err = "HTTP request failed: " + response.code.to_s
    end
    if err.blank?
      id = params[:id]
      share_type = params[:type]
      case share_type
      when 'Search'
        shared_object = Search.find_by_id(id)
      when 'Alert'
        shared_object = Alert.find_by_id(id)
      when 'Chart'
        shared_object = Chart.find_by_id(id)
      when 'Report'
        shared_object = Report.find_by_id(id)
      when 'Dashboard'
        shared_object = Dashboard.find_by_id(id)
      end
      share = Share.where(share_token: share_token).first
      ActiveRecord::Base.transaction do
        share.destroy if share
        unless shared_object.blank? # user deleted the object being shared
          shared_object.shared = nil # not shared
          shared_object.save!
        end
      end
      redirect_to shares_path, notice: "#{share_type} was unshared."
      return
    end
    redirect_to shares_path, notice: "Failed to unshare #{share_type}, error #{err}"
  end

  private

  def send_share(user, host_with_port, type, name, description, share_as_json)
    if Share.url.blank? || Share.header.blank? || Share.api_key.blank?
      return "<br />Sharing is not configured properly, please contact an administrator."
    end
    response = Typhoeus::Request.post(Share.url, headers: Share.header,
                params: {
                  email: user.email,
                  host: host_with_port,
                  api_key: Share.api_key
                },
                body: {
                  share: {
                    share_type: type,
                    name: name,
                    description: description,
                    share_as_json: share_as_json
                  }
                }
    )
    err = nil
    if response.success?
    elsif response.code == 0
      err = response.return_code.to_s
    elsif response.timed_out?
      err = "Time out: " + response.code.to_s
    else
      err = "HTTP request failed: " + response.code.to_s
    end
    err.blank? ? JSON.parse(response.body) : err + response.body
  end

  def install_share_based_on_type(share_token, share)
    share_as_hash = JSON.parse(share['share_as_json'])
    share_type = share['share_type']
    msg = "The selected share was successfully installed and a copy was made for your use." +
          "  You may make changes or use it as is, and" +
          "  the shared version is not altered by your changes."
    installed = nil
    # OPTIMIZE refactor the following
    case share_type
    when 'Search'
      search_attributes = share_as_hash.delete('search') # remove the root key 'search'
      installed = Search.install_share(current_user.id, share_token, search_attributes)
      redirect_to searches_path(id: installed.id), notice: msg and return unless installed.blank?
    when 'Alert'
      installed = Alert.install_share(current_user.id, share_token, share_as_hash)
      redirect_to alerts_path(id: installed.id), notice: msg and return unless installed.blank?
    when 'Chart'
      installed = Chart.install_share(current_user.id, share_token, share_as_hash)
      redirect_to charts_path(id: installed.id), notice: msg and return unless installed.blank?
    when 'Report'
      installed = Report.install_share(current_user.id, share_token, share_as_hash)
      redirect_to reports_path(id: installed.id), notice: msg and return unless installed.blank?
    when 'Dashboard'
      installed = Dashboard.install_share(current_user.id, share_token, share_as_hash)
      redirect_to dashboards_path(id: installed.id), notice: msg and return unless installed.blank?
    else
      redirect_to shares_path, notice: "Share type of '#{share_type}' is unknown, so it can not be installed."
    end
    redirect_to shares_path, notice: "Failed to install '#{share_type}' share, reason is unknown." if installed.blank?
  end

  def is_sharing_allowed
    # raise CanCan::NotImplemented unless Share.sharing?
  end
end