class PdfsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_reports_path
  before_action :set_pdf, only: [:show, :destroy]

  def index
    @pdfs = current_user.pdfs.order(created_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
    @pdfs = @pdfs.where(report_id: params[:id]) unless params[:id].blank?
  end

  def show
    content_type = "application/pdf"
    path = "#{current_user.id}"
    if Rails.env.production? && APP_CONFIG[:web_server] == 'nginx'
      # note: '/private_files/' == '~/apps/osprotect/shared/reports' ... see details in /etc/nginx/nginx.conf
      # use 'head()' to let nginx handle downloading the file, which frees up rails to handle other requests:
      head(x_accel_redirect: "/private_files/#{path}/" + @pdf.file_name,
           content_type: content_type,
           content_disposition: "attachment; filename=\"#{@pdf.file_name}\"")
    else
      # 'send_file()' puts the burden of downloading a file on rails, which will block while doing so:
      send_file("#{APP_CONFIG[:reports_path]}/#{path}/" + @pdf.file_name)
      # send_file("/Users/cleesmith/Sites/osProtect_ror320/shared/reports/#{path}/" + @pdf.file_name)
    end
  end

  def destroy
    file = @pdf.path_to_file + '/' + @pdf.file_name unless @pdf.path_to_file.blank? || @pdf.file_name.blank?
    @pdf.destroy
    unless file.blank?
      begin
        FileUtils.rm(file) if File.exist?(file)
      rescue Errno::ENOENT => e
        # ignore file not found coz can't delete what's not there
      end
    end
    redirect_to pdfs_url
  end

  private

  # use callbacks to share common setup or constraints between actions.
  def set_pdf
    @pdf = current_user.pdfs.find(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def pdf_params
    nil
  end

  def check_reports_path
    if Rails.env.production? && APP_CONFIG[:reports_path].include?(Rails.root.to_s)
      redirect_to root_url, alert: "Reports/PDFs are unavailable, because the reports path is within this application's folder. Please contact a system administrator."
    end
  end
end
