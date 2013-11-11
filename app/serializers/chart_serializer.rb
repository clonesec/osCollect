class ChartSerializer < ActiveModel::Serializer
  attributes  :name, :query_params, 
              :chart_type, :chart_title, :chart_json_serialized,
              :group_by, :chart_library

  has_one :search

  # self.root = false
end
