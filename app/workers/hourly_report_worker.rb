class HourlyReportWorker
  def self.perform(ignore_this)
    reports_path = APP_CONFIG[:reports_path]
    puts "HourlyReportWorker:perform ..."
    Report.where(auto_run_at: 'Hourly').where(auto_run: true).each_with_index do |report, x|
			next if report.report_charts.empty? && report.report_searches.empty?
      file_path = "#{reports_path}/#{report.user.id}"
      file_name = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_Hourly_#{report.id}_#{x+1}.pdf"
      FileUtils.mkdir_p(file_path)
      pdf = Pdf.new
      pdf.user_id = report.user.id
      pdf.report_id = report.id
      pdf.path_to_file = file_path
      pdf.file_name = file_name
      pdf.save!
      pdf.rasterize_web_page_to_pdf('Hourly')
  	  report.auto_run_count = report.auto_run_count + 1
  	  report.auto_run_last_at = Time.now.utc
  	  report.save(validate: false)
    end
  end
end
