class ReportChartSerializer < ActiveModel::Serializer
  attributes  :position

  has_one :chart

  self.root = false
end
