class DataSource < ActiveRecord::Base
  has_many :data_source_fields

  # attr_accessible :name
end
