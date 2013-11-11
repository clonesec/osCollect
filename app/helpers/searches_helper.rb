module SearchesHelper
  def fields_for_selected_datasource(id)
    fields = []
    return fields if id.blank?
    dsf = DataSource.find(id).data_source_fields.select('id, name')
    dsf.each do |f|
      fields << [f.name, f.id] unless ['timestamp', 'logtext'].include?(f.name.downcase)
    end
    fields
  end

  def get_datasources
    ds = DataSource.order(name: :asc)
    sources = []
    ds.each do |d|
      sources = sources << [d.name, d.id]
    end
    sources
  end
end
