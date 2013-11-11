class SearchSerializer < ActiveModel::Serializer
  attributes  :name, :query_params, 
              :query, :sources,
              :relative_timestamp,
              :date_from, :time_from,
              :date_to, :time_to,
              :host_from, :host_to,
              :group_by

  has_many :search_fields, key: :search_fields_attributes

  # self.root = false
end
