class ReportSerializer < ActiveModel::Serializer
  attributes  :name, :description,
              :auto_run, :auto_run_at, :auto_run_daily_hour,
              :include_summary
              # cls: don't include these:
              # , :auto_run_last_at, :auto_run_count

  has_many :report_charts, key: :report_charts_attributes
  has_many :report_searches, key: :report_searches_attributes

  # self.root = false
end
