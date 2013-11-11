class Share < ActiveRecord::Base
  # attr_accessible :user_id, :share_token, :shared_id, :share_type

  def self.installed?(user_id, share_type, share_token)
    return false if share_type.blank? || share_token.blank?
    case share_type
    when 'Search'
      found = Search.where(user_id: user_id, origin: share_token).first
      return true if found
    when 'Alert'
      found = Alert.where(user_id: user_id, origin: share_token).first
      return true if found
    when 'Chart'
      found = Chart.where(user_id: user_id, origin: share_token).first
      return true if found
    when 'Report'
      found = Report.where(user_id: user_id, origin: share_token).first
      return true if found
    when 'Dashboard'
      found = Dashboard.where(user_id: user_id, origin: share_token).first
      return true if found
    end
    false
  end

  def self.sharing?
    return false if Share.url.blank? || Share.header.blank? || Share.api_key.blank?
    true
  end

  def self.header
    return nil if APP_CONFIG[:share_api_key].blank?
    {
    'Authorization' => "Token token=\"#{APP_CONFIG[:share_api_key].downcase}\"",
    'User-Agent' => "osCollect"
    }
  end

  def self.url
    "#{APP_CONFIG[:share_url]}/shares" unless APP_CONFIG[:share_url].blank?
  end

  def self.api_key
    APP_CONFIG[:share_api_key]
  end
end