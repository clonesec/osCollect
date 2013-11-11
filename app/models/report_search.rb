class ReportSearch < ActiveRecord::Base
  belongs_to :report, inverse_of: :report_searches
  acts_as_list scope: :report
  belongs_to :search
  # attr_accessible :position, :search_id

  attr_accessor :results

  def self.install_share(report_id, search_id, report_search_hash)
    report_search = self.new(report_search_hash)
    report_search.report_id = report_id
    report_search.search_id = search_id
    report_search.save(validate: false)
    report_search
  end
end
