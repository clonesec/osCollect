class WeeklyLogCountsWorker
  def self.perform(ignore_this)
    perform_start_time = Time.now.utc
    puts "WeeklyLogCountsWorker:perform ..."
    now = Time.now.utc
    # cls: simple test using this week:
    # start_date = now.beginning_of_week(start_day = :sunday)
    # end_date = now.end_of_week(start_day = :sunday)
    start_date = (now - 1.week).beginning_of_week(start_day = :sunday)
    end_date = (now - 1.week).end_of_week(start_day = :sunday)
    # use the same time range for all log watchers:
    query = 'timestamp:[' + start_date.strftime("%Y-%m-%dT%H:%M:%SZ") + ' TO ' + end_date.strftime("%Y-%m-%dT%H:%M:%SZ") + ']'
    # FIXME maybe add a history record here ?
    Log.where('active=? AND (auto_run_at=? OR auto_run_at=?)', true, 'weekly', 'both').each do |watcher|
      WeeklyLogCountsMailer.send_log_counts(watcher.id, query, start_date.strftime("%A, %b %-d, %Y %H:%M:%S %Z"), end_date.strftime("%A, %b %-d, %Y %H:%M:%S %Z")).deliver
    end
    puts "\telapsed: #{Time.now.utc - perform_start_time} secs"
  end
end