class WeeklyReportWorker
  def self.perform(ignore_this)
    start_time = Time.now.utc
    reports_path = APP_CONFIG[:reports_path]
    puts "WeeklyReportWorker:perform ..."
    Report.where(auto_run_at: 'Weekly').where(auto_run: true).each_with_index do |report, x|
			next if report.report_charts.empty? && report.report_searches.empty?
      file_path = "#{reports_path}/#{report.user.id}"
      file_name = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_Weekly_#{report.id}_#{x+1}.pdf"
      FileUtils.mkdir_p(file_path)
      pdf = Pdf.new
      pdf.user_id = report.user.id
      pdf.report_id = report.id
      pdf.path_to_file = file_path
      pdf.file_name = file_name
      pdf.save!
      begin
        pdf.rasterize_web_page_to_pdf('Weekly')
      rescue
        # don't leave user wondering what happened to their pdf:
        pdf.run_status = "failed: PDF not created!" if pdf.run_status.blank?
        pdf.save!
      end
  	  report.auto_run_count = report.auto_run_count + 1
  	  report.auto_run_last_at = Time.now.utc
  	  report.save(validate: false)
    end
    puts "\telapsed: #{Time.now.utc - start_time} secs"
  end
end
