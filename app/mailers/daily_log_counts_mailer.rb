class DailyLogCountsMailer < ActionMailer::Base
  include Resque::Mailer

  default from: APP_CONFIG[:emails_from]

  def send_log_counts(watcher_id, query, start_datetime_s, end_datetime_s)
    @log_watcher = Log.find(watcher_id)
    @start_time = start_datetime_s
    @end_time = end_datetime_s
    @user = User.find(@log_watcher.user_id)
    # typical solr request:
    # curl --globoff "http://127.0.0.1:8983/solr/collection1/select?wt=ruby&rows=0&q=timestamp:[2013-09-16T00:00:00Z TO 2013-09-16T23:59:59Z]&facet=true&facet.field=host"
    # FIXME this should only be done once for all log watchers, somehow ?
    @total, host_counts = Search.host_counts(nil, query)
    @ip_hits = Hash[host_counts.map {|ip| [ip.value, ip.hits]}]
    none_sending = false
    @watchers = {}
    @log_watcher.host_ips.split(',').each do |ip_host_s|
  		ip_host = ip_host_s.strip.split(' ')
  		ip = ip_host.blank? ? 'unknown?' : ip_host[0]
  		hostname = ip_host[1].blank? ? '' : ip_host[1]
  		count = @ip_hits.has_key?("#{ip}") ? @ip_hits["#{ip}"] : 0
      none_sending = true if count <= 0
  		@watchers[ip] = [hostname, count]
		end
		only_email_if_none_sending = !@log_watcher.send_email && none_sending
    if @log_watcher.send_email || only_email_if_none_sending
      mail to: @user.email, subject: "osCollect: Daily Log Counts for #{@log_watcher.name} Watcher"
    else
      # All hosts sending, so no email sent!
      return
    end
  end
end
