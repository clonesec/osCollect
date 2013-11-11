class AlertSerializer < ActiveModel::Serializer
  attributes  :active,
              :logs_in_email,
              :status,
              :name,
              :description,
              :threshold_operator,
              :threshold_count,
              :threshold_time_seconds

  has_one :search

  # self.root = false
end
