class UserMailer < ActionMailer::Base
  include Resque::Mailer

  default from: APP_CONFIG[:emails_from]

  def password_reset(user_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: "Password Reset"
  end

  def alerts(user_id, search_id, alert_id, from_timestamp, to_timestamp, total)
    return # cls: do not use!
    # @user = User.find(user_id)
    # @search = Search.find(search_id)
    # @alert = Alert.find(alert_id)
    # if @alert.threshold_operator == 'gt'
    #   @threshold_operator = 'greater than'
    # else
    #   @threshold_operator = 'less than'
    # end
    # @threshold_time = @alert.threshold_time_seconds / 60
    # @from_timestamp = Time.at(from_timestamp).utc
    # @to_timestamp = Time.at(to_timestamp).utc
    # @total = total
    # if (@total <= 0) || @all_results.nil?
    #   puts "UserMailer::alerts no matches!!! nothing sent to: #{@user.email}"
    # else
    #   begin
    #     puts "UserMailer::alerts sending mail to: #{@user.email}"
    #     # mail to: @user.email, subject: "oscollect alert: #{@alert.name}", content_type: 'text/html'
    #     mail to: @user.email, subject: "oscollect alert: #{@alert.name}"
    #   rescue Exception => e
    #     puts "\nUserMailer::alerts failed with exception: #{e.message}\n"
    #   end
    # end
  end
end
