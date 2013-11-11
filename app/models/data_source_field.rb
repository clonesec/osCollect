class DataSourceField < ActiveRecord::Base
  belongs_to :data_source
  belongs_to :data_field_type
  belongs_to :data_pattern_type

  # attr_accessible :data_source_id, :data_field_type_id, :data_pattern_type_id, :name, :solr_attr_name, :input_validation, :position

  def self.groupby_fields
    dsf = DataSourceField.select('id, data_source_id, name, solr_attr_name').includes(:data_source).order(data_source_id: :asc, name: :asc)
    groupbys = []
    dsf.each do |f|
      name = "#{f.data_source.name}.#{f.name}"
      next if name.downcase == 'any.logtext'
      # attr_name = "#{f.data_source.name.gsub(' ','_').downcase}.attr_#{f.solr_attr_name}"
      # attr_name = attr_name.gsub('attr_','') if f.data_source.name.downcase == 'any'
      # groupbys << [name, attr_name]
      groupbys << [name, f.id]
    end
    groupbys
  end
end
