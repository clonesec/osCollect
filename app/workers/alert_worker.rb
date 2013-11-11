class AlertWorker
  def self.perform(ignore_this)
    start_time = Time.now.utc
  	# "big" assumption is that all of this finishes within 5 minutes
    run_time = Time.at((Time.now.utc.to_f / 60).floor * 60).utc.to_i # round down to be exactly on a minute
    # cls testing: run_time = Time.at((Time.parse("2013/04/25 02:10:00 UTC").to_f / 60).floor * 60).utc.to_i
    # puts "AlertWorker:perform  now=#{Time.now.utc}  run_time=#{Time.at((Time.now.utc.to_f / 60).floor * 60).utc}\n"
    puts "AlertWorker:perform  now=#{Time.now.utc}  run_time(#{run_time.inspect})=#{Time.at(run_time)}\n"
    User.all.each do |user|
      user.alerts.where(active: true).each do |alert|
        next if alert.search.nil?
        AlertMailer.handle_alert(alert.id, run_time).deliver
      end
    end
    puts "\telapsed: #{Time.now.utc - start_time} secs"
  end
end
