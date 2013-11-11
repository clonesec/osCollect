class DailyLogCountsWorker
  def self.perform(ignore_this)
    perform_start_time = Time.now.utc
    puts "#{perform_start_time.strftime("%Y-%m-%dT%H:%M:%SZ")} DailyLogCountsWorker:perform ..."
    now = Time.now.utc
    # cls: simple test using today:
    # yesterday_start = now.beginning_of_day
    # yesterday_end   = now.end_of_day
    yesterday_start = (now - 1.day).beginning_of_day
    yesterday_end   = (now - 1.day).end_of_day
    # use the same time range for all log watchers:
    query = 'timestamp:[' + yesterday_start.strftime("%Y-%m-%dT%H:%M:%SZ") + ' TO ' + yesterday_end.strftime("%Y-%m-%dT%H:%M:%SZ") + ']'
    # FIXME maybe add a history record here ?
    Log.where('active=? AND (auto_run_at=? OR auto_run_at=?)', true, 'daily', 'both').each do |watcher|
      DailyLogCountsMailer.send_log_counts(watcher.id, query, yesterday_start.strftime("%A, %b %-d, %Y %H:%M:%S %Z"), yesterday_end.strftime("%A, %b %-d, %Y %H:%M:%S %Z")).deliver
    end
    puts "\telapsed: #{Time.now.utc - perform_start_time} secs"
  end
end