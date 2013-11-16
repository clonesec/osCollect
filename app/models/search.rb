require 'ipaddr'

class Search < ActiveRecord::Base
  belongs_to :user
  belongs_to :search_type
  has_many :alerts, dependent: :destroy
  has_many :charts, dependent: :destroy
  has_many :report_searches, dependent: :destroy
  has_many :search_fields, inverse_of: :search, dependent: :destroy
  accepts_nested_attributes_for :search_fields, allow_destroy: true

  # attr_accessible :name, :query, :sources,
  #                 :date_from, :time_from, :date_to, :time_to, :relative_timestamp,
  #                 :host_from, :host_to,
  #                 :search_type, :group_by,
  #                 :query_params, :search_fields_attributes

  attr_accessor :from_timestamp, :to_timestamp, :from_host, :to_host, :search_type, :highlights
  serialize :sources, Array
  serialize :query_params, Hash

  # note: the order of the following validations is the order they will appear in the page/view's error list:
  # Jan 2013: allow duplicate search name's because of Sharing:
  # validates :name, uniqueness: {case_sensitive: false}
  # Jan 2013: allow a search name to contain any characters
  # validates :name,
  #           uniqueness: {case_sensitive: false},
  #           format: {
  #             with: /^(?:[a-z0-9]_?)*[a-z](?:_?[a-z0-9])*$/i,
  #             message: "of \"%{value}\" is invalid, only enter letters, numbers, and inner underscore characters"
  #           },
  #           on: :update
  validate :search_form_fields # if all is valid this sets the query_params

  scope :only_searches, -> { where(search_type_id: SearchType.find_by_usage_name('search').id) }

  # scope :only_logcasters, where(search_type_id: SearchType.find_by_usage_name('logcaster').id) # Live Logs

  def self.install_share(current_user_id, origin, search_hash)
    # before creating/installing a search, check if it exists already, if it does then return that:
    search = Search.where(user_id: current_user_id, name: search_hash['name'], query: search_hash['query']).first
    unless search.blank?
      # NOTE in case "diff" is deprecated in rails:
      # copied from: activesupport/lib/active_support/core_ext/hash/diff.rb:
      # def diff(h2)
      #   dup.delete_if { |k, v| h2[k] == v }.merge!(h2.dup.delete_if { |k, v| has_key?(k) })
      # end
      difference = {search.query_params => search_hash['query_params']}.diff(search.query_params => search_hash['query_params'])
      return search if difference.empty?
    end
    # search = self.new.from_json(search_json)
    # note : the above "from_json" does not work properly with nested associations, so do it manually:
    search = self.new(search_hash)
    search.user_id = current_user_id
    search.origin = origin
    search.save(validate: false)
    search
  end

  def self.list_saved_searches(user)
    ss = []
    user.searches.only_searches.each do |s|
      ss << [s.name, s.id]
    end
    ss
  end

  class FacetItem
    attr_reader :value, :hits
    def initialize value, hits
      @value, @hits = value, hits
    end
  end

  def self.counts_by_date
    # http://localhost:8983/solr/select/?q=*:*&rows=0&facet=true&facet.date=timestamp&facet.date.start=NOW/DAY-5DAYS&facet.date.end=NOW/DAY%2B1DAY&facet.date.gap=%2B1DAY
    # http://localhost:8983/solr/select/?
    # q=*:*&rows=0&facet=true&
    # facet.date=timestamp&
    # facet.date.start=NOW/DAY-5DAYS&
    # facet.date.end=NOW/DAY%2B1DAY&
    # facet.date.gap=%2B1DAY
    solr = RSolr.connect url: APP_CONFIG[:solr_url]
    response = solr.get 'select',
      params: {
        rows: 0, q: '*', facet: true, sort: 'timestamp desc', 
        'facet.date'        => 'timestamp',
        'facet.date.start'  => 'NOW/DAY-6DAYS',
        'facet.date.end'    => 'NOW/DAY+1DAY',
        'facet.date.gap'    => '+1DAY'
    }
    total = response["response"]["numFound"]
    facet_items = []
    response['facet_counts']['facet_dates']['timestamp'].map do |(adate, counts)|
      next if ['gap','start','end'].include?(adate.downcase)
      facet_items << FacetItem.new("#{Time.parse(adate).strftime('%Y/%m/%d %a')}", counts)
    end
    return total, facet_items
  end

  def self.facet_counts(field_name)
    solr = RSolr.connect url: APP_CONFIG[:solr_url]
    response = solr.get 'select', params: {rows: 0, q: '*', facet: true, 'facet.field'=>field_name, 'facet.limit'=>-1}
    total = response["response"]["numFound"]
    facet_items = []
    response['facet_counts']['facet_fields'].map do |(facet_field_name, values_and_hits)|
      values_and_hits.each_slice(2) do |k,v|
        ip_string = k
        facet_items << FacetItem.new(ip_string, v)
      end
    end
    return total, facet_items
  end

  def self.host_counts(excluded_host_ips, query='*')
    solr = RSolr.connect url: APP_CONFIG[:solr_url]
    # note: "rows: 0" means do not return query results but just the facets/counts:
    response = solr.get 'select', params: {rows: 0, q: query, facet: true, 'facet.field'=>'host', 'facet.limit'=>-1}
    # response = solr.get 'select', params: {rows: 0, q: "* AND host:3232235925", facet: true, 'facet.field'=>'host'}
    # response = solr.get 'select', params: {rows: 0, q: "* AND host:[3232235925 TO 3232235925]", facet: true, 'facet.field'=>'host'}
    # response = solr.get 'select', params: {rows: 0, q: '*', facet: true, 'facet.field'=>['host','source']}
    total = response["response"]["numFound"]
    facet_items = []
    response['facet_counts']['facet_fields'].map do |(facet_field_name, values_and_hits)|
      values_and_hits.each_slice(2) do |k,v|
        # ip_string = ip_numeric_to_s(k.to_i).to_s
        ip_string = k
        facet_items << FacetItem.new(ip_string, v)
      end
    end
    return total, facet_items
  end

  def perform_groupby(excluded_host_ips)
    solr = RSolr.connect url: APP_CONFIG[:solr_url]
    attr_is_ip = self.query_params['groupby_attr_ip_type'].downcase == 'ipv4' ? true : false
    facet_field = self.query_params['groupby_solr_attr_name']
    # note: "rows: 0" means do not return query results but just the facets/counts:
    solr_params = {rows: 0, facet: true, 'facet.field' => facet_field, 'facet.limit'=>-1}
    solr_params[:q] = create_query
    # use filter query (fq) for timestamp and host, if present:
    fq = create_filter_query
    solr_params[:fq] = fq unless fq.blank? 
    response = solr.get 'select', params: solr_params
    # response = solr.get 'select', params: {rows: 0, q: "* AND host:3232235925", facet: true, 'facet.field'=>'host'}
    # response = solr.get 'select', params: {rows: 0, q: "* AND host:[3232235925 TO 3232235925]", facet: true, 'facet.field'=>'host'}
    # response = solr.get 'select', params: {rows: 0, q: '*', facet: true, 'facet.field'=>['host','source']}
    total = response["response"]["numFound"] || 0
    facet_items = []
    response['facet_counts']['facet_fields'].map do |(facet_field_name, values_and_hits)|
      values_and_hits.each_slice(2) do |k,v|
        label = k
        # label = ip_numeric_to_s(k.to_i).to_s if attr_is_ip
        facet_items << FacetItem.new(label, v)
      end
    end
    return total, facet_items
  end

  def perform(excluded_host_ips, rows=50)
    solr = RSolr.connect url: APP_CONFIG[:solr_url]
    # 1. allow user to set "rows" in their profile: [50, 100, 500, 1000]
    # 2. allow user to select sort order on search page ?
    max_rows = rows
    solr_params = {rows: max_rows, sort: 'timestamp desc'}
    solr_params[:q] = create_query
    # use filter query (fq) for timestamp and host, if present:
    fq = create_filter_query
    solr_params[:fq] = fq unless fq.blank? 
    begin
      response = solr.get 'select', params: solr_params
    rescue Errno::ECONNREFUSED
      self.errors.add('Solr: ', "unable to connect.")
    rescue RSolr::Error::Http => rsolr_error
      self.errors.add('Solr: ', "syntax error.  Check your query/search then try again.")
      # puts rsolr_error.response[:body].class
      # puts rsolr_error.response[:body].to_yaml
    rescue Exception => e
      self.errors.add('Solr: ', e.message)
      # puts e.to_yaml
    end
    response
  end

  def source_ids_to_names
    source_ids = self.sources
    source_ids.delete_if {|s| s == ''}
    source_names = source_ids.map { |id| DataSource.find(id).name }
  end

  def fields_with_errors
    # see: app/views/searches/_select_chain.html.erb for usage
    errs = []
    self.errors.full_messages.each do |errmsg|
      num = /#(\d+):/.match(errmsg)
      num = num.to_s.gsub("#",'').gsub(":",'').to_i
      errs << num unless num <= 0
    end
    errs
  end

  def serialize_into_query_params
    set_query_params
  end

  def self.valid_query_string?(q)
    return true if q.blank?
    # regexp allows: \w=alphanumeric=Aa-Zz0-9, spaces, '"=quotes, \-=hyphens, .=periods, 
    #                \/=slashes, :=colons, ()=parentheses, %=percents, @=at, |=or, &=and, !=not, %=percent
    (q.strip =~ /^[\w '"\-.\/:()@|&!%]+$/) ? true : false
  end

  def self.valid_attribute_value_string?(q)
    return true if q.blank?
    # regexp allows: \w=alphanumeric=Aa-Zz0-9, spaces, '"=quotes, \-=hyphens, .=periods, 
    #                \/=slashes, :=colons, ()=parentheses, %=percents
    (q.strip =~ /^[\w '"\-.\/:()%]+$/) ? true : false
  end

  def self.email?(token)
    token =~ /^[^@]*[a-z0-9][^@]*@[^@]*[a-z0-9][^@]*$/i ? true : false
  end

  def self.numeric?(object)
    return true if object.blank?
    true if Integer(object) rescue false
  end

  def self.ip_is_valid?(ip)
    return true if ip.blank?
    IPAddr.new(ip, Socket::AF_INET).to_i
    true
  rescue Exception => e
    false
  end

  def self.ip_string_to_numeric(ip)
    # note: ip address families:
    #       Socket::AF_INET  =  2 = ipv4
    #       Socket::AF_INET6 = 30 = ipv6
    # IPAddr.new(ip, Socket::AF_INET).to_i # just for ipv4
    # to handle either ipv4/6 don't specify the family:
    IPAddr.new(ip).to_i
  rescue Exception => e
    return e.message
  end

  def ip_string_to_numeric(ip_string)
    # note: ip address families:
    #       Socket::AF_INET  =  2 = ipv4
    #       Socket::AF_INET6 = 30 = ipv6
    IPAddr.new(ip_string, Socket::AF_INET).to_i # just for ipv4
    # to handle either ipv4/6 don't specify the family:
    # IPAddr.new(ip_string).to_i
  rescue Exception => e
    nil
  end

  def self.ip_numeric_to_s(ip)
    ip.is_a?(Integer) ? IPAddr.new(ip, Socket::AF_INET) : IPAddr.new(ip.to_s)
  end

  def ip_numeric_to_s(ip)
    ip.is_a?(Integer) ? IPAddr.new(ip, Socket::AF_INET) : IPAddr.new(ip.to_s)
  end

  private

  def create_query
    # date/time range query:
    # fq=timestamp:[NOW-55MINUTES TO NOW]
    # params'=>{
    #   'facet'=>'true',
    #   'q'=>'*:*',
    #   'facet.field'=>'timestamp',
    #   'fq'=>'timestamp:[NOW-55MINUTES TO NOW]'}
    # }
    q = self.query.blank? ? '*' : 'logtext:(' + self.query + ')'
    # unless self.from_timestamp.blank? && self.to_timestamp.blank?
    #   q += " AND timestamp:[#{self.from_timestamp} TO #{self.to_timestamp}]"
    # end
    # unless self.from_host == 0 && self.to_host == 0
    #   q += " AND host:[#{self.from_host} TO #{self.to_host}]"
    # end
    # cls: the "+ fields" should be in the filter query, maybe, but
    #      it's difficult to handle AND's & OR's:
    self.query_params['match_fields'].each do |key, field|
      q += " #{field['ao']} #{field['solr_name']}:(#{field['value']})"
    end
    q
  end

  def create_filter_query
    # regarding using a filter query (fq) in solr:
    # "... very useful for speeding up complex queries since the queries
    #      specified with fq are cached independently from the main query ..."
    # see: http://wiki.apache.org/solr/CommonQueryParameters#fq
    fq = []
    unless blank_or_zero?(self.query_params['from_timestamp']) || blank_or_zero?(self.query_params['to_timestamp'])
      fq << "timestamp:[#{self.query_params['from_timestamp']} TO #{self.query_params['to_timestamp']}]"
    end
    unless blank_or_zero?(self.query_params['from_host']) || blank_or_zero?(self.query_params['to_host'])
      fq << "host_l:[#{self.query_params['from_host']} TO #{self.query_params['to_host']}]"
    end
    fq
  end

  def blank_or_zero?(obj)
    obj.blank? || obj == 0
  end

  def search_form_fields
    @highlights = ""
    self.from_timestamp = self.to_timestamp = self.from_host = self.to_host = 0
    plus_criteria_count = 0
    self.search_fields.each_with_index do |sf, entryx|
      source = DataSource.find(sf.data_source_id)
      if source.blank?
        add_to_search_errors(entryx, sf, "a data source must be selected", false)
        return
      end
      field = DataSourceField.find(sf.data_source_field_id)
      if field.blank?
        add_to_search_errors(entryx, sf, "a field must be selected", false)
        return
      end
      # oper = DataFieldOperator.find(sf.data_field_operator_id)
      # cls: for now, only use "=":
      oper = DataFieldOperator.find(1)
      if oper.blank?
        add_to_search_errors(entryx, sf, "a boolean operator must be selected", false)
        return
      end
      if sf.match_or_attribute_value.blank?
        add_to_search_errors(entryx, sf, "match value missing", false)
        return
      end
      @highlights += sf.match_or_attribute_value.split(' ').join(' ') + ' '
      data_field_type = DataFieldType.find(field.data_field_type_id)
      if data_field_type.blank?
        add_to_search_errors(entryx, sf, "unknown field type: must be integer or string", false)
        return
      else
        field_type = data_field_type.field_type
      end
      input_validation = field.input_validation.blank? ? '' : field.input_validation.downcase
      if input_validation == 'ipv4'
        if source.name.downcase == 'any' && field.name.downcase == 'host'
          # ignore
        else
          ip_addr = ip_string_to_numeric(sf.match_or_attribute_value)
          if ip_addr.nil?
            add_to_search_errors(entryx, sf, "IP address is invalid, must be 0.0.0.0 to 255.255.255.255", false)
            return
          end
        end
      elsif field_type == 'int'
        unless Search.numeric?(sf.match_or_attribute_value)
          add_to_search_errors(entryx, sf, "value must be numeric (0-9)", false)
          return
        end
      else
        unless ['=', '!='].include?(oper.operator)
          add_to_search_errors(entryx, sf, "'#{field.name.downcase}' and all string type fields only support '=' and '!=', but not #{oper.operator}", false)
          return
        end
      end
      plus_criteria_count += 1
    end
    unless self.query.blank?
      @highlights += self.query.split(' ').join(' ')
      @highlights = @highlights.gsub('@', '').gsub('!', '').gsub('&', '').gsub('|', '').split(' ').uniq
    end
    process_timestamp_from_to
    self.errors.add('Time range:', "entering both 'select an interval' and a time range is not allowed") if self.relative_timestamp.present? && (self.from_timestamp.present? || self.to_timestamp.present?)
    process_relative_timestamp if self.relative_timestamp.present? && (self.from_timestamp.blank? && self.to_timestamp.blank?)
    process_host_from_to
    set_query_params unless self.errors.any?
  end

  def add_to_search_errors(x, field, errmsg, prefix_error_to_field=true)
    self.errors.add(:base, "##{x+1}: " + errmsg)
    field.match_or_attribute_value = "##{x+1}:ERROR:" + errmsg + '->' + field.match_or_attribute_value if prefix_error_to_field
    # cls: this causes double validations so don't do it since we no longer auto-save searches:
    # field.save(validate: false)
  end

  def process_host_from_to
    self.from_host = self.to_host = 0
    unless host_from.blank?
      self.from_host = ip_string_to_numeric(host_from)
      self.errors.add('Host IP begin', "is invalid") and return if self.from_host.nil?
    end
    unless host_to.blank?
      self.to_host = ip_string_to_numeric(host_to)
      self.errors.add('Host IP end', "is invalid") and return if self.to_host.nil?
    end
    self.to_host = 4294967295 if host_from.present? && host_to.blank? # mysql max int = 255.255.255.255
  end

  def to_datetime(date_string, time_string)
    format = time_string.blank? ? '%m/%d/%Y' : '%m/%d/%Y %H:%M:%S'
    date_time = time_string.blank? ? date_string : date_string + ' ' + time_string
    DateTime.strptime(date_time, format)
  rescue Exception => e
    nil
  end

  def process_timestamp_from_to
    self.from_timestamp = self.to_timestamp = nil
    self.errors.add('From date', "is missing, but time was entered") and return if time_from.present? && date_from.blank?
    self.errors.add('To date', "is missing, but time was entered") and return if time_to.present? && date_to.blank?
    unless date_from.blank?
      from = to_datetime(date_from, time_from)
      self.errors.add('From date', "is invalid") and return if from.nil?
      self.from_timestamp = from.utc.beginning_of_day.to_i if time_from.blank?
      self.from_timestamp = from.utc.to_i if time_from.present?
      if date_to.blank?
        # user didn't enter a "to date" so let's set it to way in the future:
        self.to_timestamp = (Time.now + 1000.years).utc.end_of_day.to_i
        self.to_timestamp = Time.at(self.to_timestamp).utc.iso8601
      end
      # just convert timestamp epoch number to iso8601 (solr):
      self.from_timestamp = Time.at(self.from_timestamp).utc.iso8601
    end
    unless date_to.blank?
      to = to_datetime(date_to, time_to)
      self.errors.add('To date', "is invalid") and return if to.nil?
      self.to_timestamp = time_to.present? ? to.utc.to_i : to.utc.end_of_day.to_i
      if date_from.blank?
        # user didn't enter a "from date" so let's set it to way in the past:
        self.from_timestamp = 0
        self.from_timestamp = Time.at(self.from_timestamp).utc.iso8601
      end
      # just convert timestamp epoch number to iso8601 (solr):
      self.to_timestamp = Time.at(self.to_timestamp).utc.iso8601
    end
  end

  def process_relative_timestamp
    self.from_timestamp = self.to_timestamp = 0
    return if self.relative_timestamp.blank?
    case self.relative_timestamp.to_sym
    when :today
      self.from_timestamp = Time.now.utc.beginning_of_day.to_i
      self.to_timestamp = Time.now.utc.end_of_day.to_i
    when :last24
      self.from_timestamp = Time.now.utc.yesterday.to_i
      self.to_timestamp = Time.now.utc.to_i
    when :yesterday
      self.from_timestamp = (Time.now.utc - 1.day).beginning_of_day.to_i
      self.to_timestamp = (Time.now.utc - 1.day).end_of_day.to_i
    when :pastweek
      self.from_timestamp = (Time.now.utc - 1.week).to_i
      self.to_timestamp = Time.now.utc.to_i
    end
    # just convert timestamp epoch number to iso8601 (solr):
    self.from_timestamp = Time.at(self.from_timestamp).utc.iso8601
    self.to_timestamp = Time.at(self.to_timestamp).utc.iso8601
  end

  def set_query_params
    self.query_params = {}
    log_sources = self.source_ids_to_names
    self.query_params['groupby_source'] = self.query_params['groupby_name'] = ''
    self.query_params['groupby_solr_attr_name'] = self.query_params['groupby_attr_ip_type'] = ''
    self.query_params['groupby_attr_position'] = 0
    unless self.group_by.blank?
      field = DataSourceField.find(self.group_by)
      self.query_params['groupby_source'] = field.data_source.name.gsub(' ', '_').downcase
      # self.query_params['groupby_name'] = (self.query_params['groupby_source'] == 'any') ? field.sphinx_attr_name.downcase : field.name.downcase
      self.query_params['groupby_name'] = field.name.downcase
      self.query_params['groupby_attr_position'] = field.position
      # self.query_params['groupby_sphinx_attr_name'] = (field.position < 5) ? field.sphinx_attr_name : "attr_#{field.sphinx_attr_name}"
      if field.data_source.name.downcase == 'any'
        self.query_params['groupby_solr_attr_name'] = field.solr_attr_name
      else
        self.query_params['groupby_solr_attr_name'] = self.query_params['groupby_source'] + '_' + field.solr_attr_name
      end
      self.query_params['groupby_attr_ip_type'] = field.input_validation.blank? ? '' : field.input_validation.downcase
    end
    self.query_params['from_timestamp'] = self.from_timestamp
    self.query_params['to_timestamp'] = self.to_timestamp
    self.query_params['from_host'] = self.from_host
    self.query_params['to_host'] = self.to_host
    self.query_params['sources'] = {}
    self.query_params['query'] = self.query.gsub("\r",'').gsub("\n",'')
    # cls: for solr we are only using query_params['match_fields'], i.e. there's no i0-5 or s0-5:
    self.query_params['filter_fields'] = {} # int type (i0-5)
    self.query_params['match_fields'] = {}  # string type (s0-5)
    ffs = mfs = 0
    self.search_fields.each do |sf|
      dsf = DataSourceField.find(sf.data_source_field_id)
      next if dsf.blank?
      field_type = DataFieldType.find(dsf.data_field_type_id).field_type
      next if field_type.blank?
      plus_field = {}
      plus_field['ao'] = sf.and_or.upcase
      plus_field['source'] = DataSource.find(sf.data_source_id).name
      log_sources << plus_field['source']
      plus_field['field_name'] = dsf.name
      plus_field['field_type'] = field_type
      # plus_field['operator'] = DataFieldOperator.find(sf.data_field_operator_id).operator
      plus_field['operator'] = nil
      plus_field['value'] = sf.match_or_attribute_value
      input_validation = dsf.input_validation.blank? ? '' : dsf.input_validation.downcase
      if plus_field['source'].downcase == 'any'
        if plus_field['field_name'].downcase == 'host'
          plus_field['solr_name'] = 'host'
        else
          plus_field['solr_name'] = dsf.solr_attr_name
        end
      else
        plus_field['solr_name'] = plus_field['source'].gsub(' ', '_').downcase + '_' + dsf.solr_attr_name
        plus_field['solr_name'] = plus_field['solr_name'] + '_l' if input_validation == 'ipv4'
      end
      if input_validation == 'ipv4'
        plus_field['value'] = self.ip_string_to_numeric(sf.match_or_attribute_value) unless plus_field['solr_name'] == 'host'
      end
      self.query_params['match_fields'][mfs] = plus_field
      mfs += 1
    end
    log_sources << self.query_params['groupby_source'] unless self.query_params['groupby_source'].blank?
    log_sources.uniq!
    # query_params must be hashes/integers/strings, as arrays don't work -- a typhoeus issue? ... so do this:
    log_sources.each_with_index do |s,x|
      self.query_params['sources'][x] = s
    end
  end
end
