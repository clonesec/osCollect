class Pdf < ActiveRecord::Base
  belongs_to :user
  belongs_to :report

  def rasterize_web_page_to_pdf(type='RunNow')
    start_time = Time.now.utc
    # puts "\tPdf:rasterize_web_page_to_pdf ..."
    self.last_run = Time.now.utc
    url = "http://#{APP_CONFIG[:reports_url]}/printable/#{self.report_id}/#{self.user_id}/#{type}"
    pdf_file = "#{self.path_to_file}/#{self.file_name}"
    paper_size = "Letter"
    render_time_out = "#{APP_CONFIG[:phantomjs_rasterize_page_render_time_out]}"
    cmd = "#{APP_CONFIG[:phantomjs]} #{APP_CONFIG[:rasterizejs]} #{url} \"#{pdf_file}\" \"#{paper_size}\" #{render_time_out}"
    phantomjs_start_time = Time.now.utc
    # cls: ways to run a command line program:
    #   result = system(cmd) # only returns true/false
    #   result = `#{cmd}` # same as %x
    #   result = %x[#{cmd} 2>&1] # redirect stderr to stdout
    # ... after trying each of these, only "system(cmd)" works properly in background jobs,
    #     at least for Resque, otherwise ''(ticks) and %x[] hang up the worker
    # puts "\t\t\tabout to run cmd: #{cmd}"
    result = system(cmd) # only returns true/false
    unless $?.exitstatus == 0
      puts "\t\t\tphantomjs exitstatus not 0 ... result: #{result.inspect}"
    end
    phantomjs_elapsed_time = Time.now.utc - phantomjs_start_time
    # puts "\t\t\tphantomjs elapsed: #{phantomjs_elapsed_time} secs"
    if File.exist?(pdf_file)
      self.run_status = "done"
    else
      self.run_status = "failed: PDF not created: #{result}"
    end
    save(validate: false)
    elapsed = Time.now.utc - start_time
    # puts "\t\telapsed: #{elapsed} secs"
    msg = "PDF: #{self.file_name}
      generated in #{phantomjs_elapsed_time} seconds
      status: #{self.run_status}
    "
    sql = "REPLACE INTO report_histories
      SET row_id = (SELECT COALESCE(MAX(id), 0) % #{APP_CONFIG[:max_report_history]} + 1 FROM report_histories AS t),
          report_id = #{self.report_id},
          message = \"#{msg}\",
          elapsed_time = #{elapsed};
    "
    ActiveRecord::Base.connection.execute sql
  end

  # notes:
  #  - in a background worker do:
  #  (1) use command line PhantomJS to rasterize html+css+js+gcharts to create a single .pdf file
  #       phantomjs public/rasterize.js http://localhost:3000/printable/1/2 dash_1_2.pdf "2200px*2100px" <-works!
  #       phantomjs public/rasterize.js http://localhost:3000/printable/1/2 dash_1_2.pdf "A4"
  #       phantomjs public/rasterize.js http://localhost:3000/printable/1/2 dash_1_2.pdf "Letter"
  #     1. involves waiting 3+ seconds for google to render charts
  #         e.g. 5 charts average 3 seconds to render ... issue is google latency/accessibility
  #         - or give up on google and instead use Morris.js, Raphael, Rickshaw
  #     2. how to know when charts are fully rendered ?
  #         maybe use PhantomJS waitfor.js and listen for 'ready' event on each chart
  #     - pros: simple with just one .pdf file to manage
  #     - cons:
  #       1. ensuring all charts are rendered before creating .pdf file
  #       2. multiple charts cross over page boundaries and look ugly
  #           ... how to paginate ? ... one per page would be nice
  #       ************************************************************************************
  #         note: [2.] was solved by using the proper CSS to cause page breaks between charts
  #         therefore, we can use PhantomJS to create a single .pdf file from an html page
  #         with one or more charts ... yeah! ... no need for (2) below
  #       ************************************************************************************
  #
  #  ... or ...
  #
  #  (2) use command line PhantomJS to rasterize html+css+js+gcharts to .png files,
  #      then combine .png files into a .pdf using Prawn
  #       phantomjs public/rasterize.js http://localhost:3000/printable_chart/1/2 chart_1_2.png
  #     - pros: pagination is easy with Prawn
  #     - cons:
  #       1. managing all of those .png files
  #       2. less efficient, more time consuming, and more 'moving parts' than doing a single .pdf file
end
