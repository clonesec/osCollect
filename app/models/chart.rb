class Chart < ActiveRecord::Base
  belongs_to :user
  belongs_to :search
  has_many :widgets, dependent: :destroy
  has_many :report_charts, dependent: :destroy

  # attr_accessible :search_id, :chart_library, :name, :chart_type, :chart_title, 
  #                 :chart_json_serialized, :group_by, :query_params

  attr_accessor :total, :results, :widget_id

  serialize :query_params, Hash

  validates :name, presence: true
  validates :chart_type, presence: true
  validates :chart_title, presence: true
  validates :group_by, presence: true
  validates :search_id, presence: {message: "must be selected"}
  
  before_save :copy_search_query_params_to_self

  def self.install_share(current_user_id, origin, chart_hash)
    chart_attributes = chart_hash.delete('chart') # remove the root key 'chart', if it exists
    chart_attributes = chart_hash if chart_attributes.blank? # root key was not found, so just use chart_hash
    search_attributes = chart_attributes.delete('search') # remove search from chart attributes
    search = Search.install_share(current_user_id, origin, search_attributes)
    chart = self.new(chart_attributes)
    chart.user_id = current_user_id
    chart.search_id = search.id
    chart.origin = origin
    chart.save(validate: false)
    chart
  end

  def self.list_charts(user)
    charts = []
    user.charts.each do |chart|
      # Jan 2013: do not list charts without a valid search (i.e. user deleted search without editing chart)
      next if chart.search.nil?
      charts << [chart.name, chart.id]
    end
    charts
  end

  def self.chart_libraries
    chart_libraries = []
    chart_libraries << ['Local/Internal using Flotr2', 'flotr2']
    chart_libraries << ['Remote/Externel using Google Chart Tools API', 'gchart']
  end

  def self.chart_types(chart_library)
    chart_types = []
    if chart_library == 'gchart'
      Chart.select("DISTINCT(chart_type)").where(Chart.arel_table['chart_type'].not_eq(nil)).order(chart_type: :asc).each do |ct|
        next if ct.chart_type.blank?
        chart_types << [ct.chart_type, ct.chart_type]
      end
      chart_types << ['BarChart',     'BarChart']
      chart_types << ['ColumnChart',  'ColumnChart']
      chart_types << ['LineChart',    'LineChart']
      chart_types << ['PieChart',     'PieChart']
      chart_types << ['Table',        'Table']
      chart_types.uniq.sort
    else
    end
  end
  
  def copy_search_query_params_to_self
    search = Search.find(self.search_id)
    self.query_params = search.query_params
    unless search.query_params.blank?
      log_sources = []
      field = DataSourceField.find(self.group_by)
      self.query_params['groupby_source'] = field.data_source.name.gsub(' ', '_').downcase
      # self.query_params['groupby_name'] = (self.query_params['groupby_source'] == 'any') ? field.sphinx_attr_name.downcase : field.name.downcase
      self.query_params['groupby_name'] = field.name.downcase
      self.query_params['groupby_attr_position'] = field.position
      # self.query_params['groupby_solr_attr_name'] = (field.position < 5) ? field.sphinx_attr_name : "attr_#{field.sphinx_attr_name}"
      self.query_params['groupby_solr_attr_name'] = field.solr_attr_name
      self.query_params['groupby_attr_ip_type'] = field.input_validation.blank? ? '' : field.input_validation.downcase
      log_sources << self.query_params['groupby_source'] unless self.query_params['groupby_source'].blank?
      log_sources.uniq!
      # query_params must be hashes/integers/strings, as arrays don't work -- a typhoeus issue? ... so do this:
      log_sources.each_with_index do |s,x|
        self.query_params['sources'][x] = s
      end
    end
  end
end
