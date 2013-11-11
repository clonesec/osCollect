class SearchField < ActiveRecord::Base
  belongs_to :search, inverse_of: :search_fields
  belongs_to :data_source
  belongs_to :data_source_field
  belongs_to :data_field_operator
  # attr_accessible :search_id, :data_source_id, :data_source_field_id, :data_field_operator_id,
  #                 :match_or_attribute_value, :and_or

  validates_presence_of :search
  # validates :data_source_id, presence: true
  # validates :data_source_field_id, presence: true
  # validates :data_field_operator_id, presence: true
  # validates :match_or_attribute_value, presence: true
end
