app_config = YAML.load_file(Rails.root.join('config', 'app_config.yml'))
if app_config.nil? || app_config[Rails.env].nil?
  # do the following so we don't have ugly 'if..else's in our code:
  APP_CONFIG = Hash.new
  APP_CONFIG[:web_server] = 'unknown'
  APP_CONFIG[:host] = 'unknown'
  APP_CONFIG[:per_page] = 12
else
  # 'config/app_config.yml' was found so let's try to use those settings:
  APP_CONFIG = app_config[Rails.env].symbolize_keys
  APP_CONFIG[:per_page] = 12 if APP_CONFIG[:per_page].blank?
  APP_CONFIG[:per_page] = 50 if APP_CONFIG[:per_page] > 50 # max is 50
end
