class SearchFieldSerializer < ActiveModel::Serializer
  attributes  :data_source_id, :data_source_field_id, :data_field_operator_id,
              :and_or, :match_or_attribute_value

  self.root = false
end
