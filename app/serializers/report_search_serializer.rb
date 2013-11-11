class ReportSearchSerializer < ActiveModel::Serializer
  attributes  :position

  has_one :search

  self.root = false
end
