class AlertMailer < ActionMailer::Base
  include Resque::Mailer

  default from: APP_CONFIG[:emails_from]

  def handle_alert(alert_id, run_time)
    start_time = Time.now.utc
    self.message.perform_deliveries = true
    @alert = Alert.find(alert_id)
    @alert.last_run = 0 if @alert.last_run.nil?
    #     first run for alert       previously critical       threshold reached so run alert again
    # if (@alert.last_run <= 0) || (@alert.status == 'c') || ((run_time - @alert.last_run) >= @alert.threshold_time_seconds)
  	# cls: don't run Alert just coz status was previously critical:
    if (@alert.last_run <= 0) || ((run_time - @alert.last_run) >= @alert.threshold_time_seconds)
      @user = @alert.user
  		@search = @alert.search
  		return if @search.nil? # just in case the user modifies this Alert
  		# adjust timestamp range in query_params:
  		@search.from_timestamp = run_time - @alert.threshold_time_seconds # threshold_time_seconds = 300 = 5.minutes.ago
  		@search.to_timestamp = run_time
      # override the from_timestamp/to_timestamp in search.query_params using solr format:
      @search.query_params['from_timestamp'] = Time.at(@search.from_timestamp).utc.iso8601
      @search.query_params['to_timestamp']   = Time.at(@search.to_timestamp).utc.iso8601
      # note: don't save @search coz we have altered the timestamps to suit our run time interval
      # @all_results = @search.perform(GroupNode.allowed_list(@user), GroupExclude.host_ip_list(@user))
      @all_results = @search.perform(GroupExclude.host_ip_list(@user))
      total_matches = @all_results["response"]["numFound"]
      puts "\ttotal_matches=#{total_matches.inspect} for #{@search.query_params['from_timestamp']} - #{@search.query_params['to_timestamp']}\n"
      @alert.last_total_matches = total_matches
  		alert_fired = false
  		if @alert.threshold_operator == 'gt'
    		alert_fired = (total_matches > @alert.threshold_count)
		  else
    		alert_fired = (total_matches < @alert.threshold_count)
	    end
  		if alert_fired
        # puts "\t MATCHES ... alert_fired=#{alert_fired.inspect}\n"
  	    if @alert.status == 'n' # normal
  	      @alert.status = 'c' # critical
  	      @alert.last_status_change = run_time
  			end
        if @alert.threshold_operator == 'gt'
          @threshold_operator = 'greater than'
        else
          @threshold_operator = 'less than'
        end
        @threshold_time = @alert.threshold_time_seconds / 60
        @from_timestamp = Time.at(@search.from_timestamp).utc
        @to_timestamp = Time.at(@search.to_timestamp).utc
        @total = total_matches
        if (@total <= 0) || @all_results.nil?
          # puts "AlertMailer::handle_alert no matches! nothing sent to: #{@user.email}"
        else
          # puts "--->>> AlertMailer::handle_alert SENDING mail to: #{@user.email}\n\n"
          mail to: @user.email, subject: "oscollect alert: #{@alert.name}"
        end
  		else
        # puts "\t NO MATCHES ... alert_fired=#{alert_fired.inspect}\n"
        self.message.perform_deliveries = false
  	    if @alert.status == 'c' # critical
  	      @alert.status = 'n' # normal
  	      @alert.last_status_change = run_time
  			end
			end
      sql = "REPLACE INTO alert_histories
        SET row_id = (SELECT COALESCE(MAX(id), 0) % #{APP_CONFIG[:max_alert_history]} + 1 FROM alert_histories AS t),
            alert_id = #{@alert.id},
            start_time = #{@search.from_timestamp},
            end_time = #{@search.to_timestamp},
            matches = #{total_matches},
            elapsed_time = #{(Time.now.utc - start_time)};
      "
      ActiveRecord::Base.connection.execute sql
  	  @alert.last_run = run_time
  	  @alert.save(validate: false) # note: this might fail if user deletes this alert
	  else
      # puts "\tAlert was NOT run ***"
  	end
  rescue Exception => e
    puts "AlertMailer::handle_alert failed with exception: #{e.message}\n\n"
  end

end
