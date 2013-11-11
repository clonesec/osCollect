class PdfWorker
  def perform(id, type='RunNow')
    return  # Jan 2013: deprecate RunNow as it makes no sense for Daily/Weekly reports
    pdf = Pdf.find(id)
    if pdf.blank?
      pdf.run_status = "failed: PDF not created: unable to find PDF record for this report"
      pdf.save(validate: false)
      return
    end
    pdf.rasterize_web_page_to_pdf(type)
    # pdf = Pdf.find(id)
    # pdf.last_run = Time.now.utc
    # if pdf.blank?
    #   pdf.run_status = "failed: PDF not created: unable to find PDF record for this report"
    #   pdf.save(validate: false)
    #   return
    # end
    # url = "http://#{APP_CONFIG[:reports_url]}/printable/#{pdf.report_id}/#{pdf.user_id}/#{type}"
    # pdf_file = "#{pdf.path_to_file}/#{pdf.file_name}"
    # # idea: use different rasterize scripts depending on how many charts+searches for a report:
    # rasterize_js = "#{APP_CONFIG[:rasterize_path]}/rasterize_10secs.js"
    # # create_pdf = "APP_CONFIG[:phantomjs_path]/phantomjs #{rasterize_js} #{url} \"#{pdf_file}\" \"2200px*2100px\""
    # # create_pdf = "APP_CONFIG[:phantomjs_path]/phantomjs #{rasterize_js} #{url} \"#{pdf_file}\" \"A4\""
    # create_pdf = "#{APP_CONFIG[:phantomjs_path]}/phantomjs #{rasterize_js} #{url} \"#{pdf_file}\" \"Letter\""
    # # ways to run a command line program:
    # #   result = system(create_pdf) # only returns true/false
    # #   result = `#{create_pdf}` # same as %x
    # result = %x[#{create_pdf} 2>&1] # redirect stderr to stdout
    # if File.exist?(pdf_file)
    #   pdf.run_status = "done"
    # else
    #   pdf.run_status = "failed: PDF not created: #{result}"
    # end
    # pdf.save(validate: false)
  end
end
