admin = User.where(username: 'admin').first
if admin
  puts "admin found: id: #{admin.id}"
else
  puts "admin not found, so creating it!"
  # create at least one admin user:
  u = User.create!(username: 'admin', email: 'change_me@gmail.com', password: 'change_me', password_confirmation: 'change_me')
  # create admins group and a default membership for admin user:
  g = Group.create!(name: 'admins', user_ids: u.id)
  # see the 'after_save' callback in the Group model for how this user is assigned the admin role
end

found = SearchType.count > 0
unless found
  SearchType.create! usage_name: 'search'
  SearchType.create! usage_name: 'logcaster'
end

found = SentinelSearchType.where(name: 'Syslog_Sphinx').first
unless found
  SentinelSearchType.create! name: 'Syslog_Sphinx'
  SentinelSearchType.create! name: 'osProtect_Snort'
end

found = Sentinel.count > 0
unless found
  type_id = SentinelSearchType.where(name: 'Syslog_Sphinx').first.id
  Sentinel.create!  name:                     'Willow',     # Bristlecone
                    url_domain_ip:            '127.0.0.1',  # 50.116.50.120
                    sentinel_search_type_id:  type_id,
                    url_protocol:             'http',
                    url_port:                 8080,
                    info_path:                'info',
                    info_http_method:         'get',
                    browse_path:              'browse',
                    browse_http_method:       'get',
                    search_path:              'search',
                    search_http_method:       'post',
                    groupby_path:             'groupby',
                    groupby_http_method:      'post',
                    request_timeout:          10000, # milliseconds
                    max_concurrent_requests:  12
end

# i0  i1  i2  i3  i4  i5   s0  s1  s2  s3  s4  s5 <-- syslogs_template
#  5   6   7   8   9  10   11  12  13  14  15  16 <-- field_order column in fields_classes_map
found = FieldOrderToSphinxAttr.where(field_order: 16).first
unless found
  # note: the 'msg' column is not included in this list as it is the column/data that is indexed by sphinx!
  FieldOrderToSphinxAttr.create! field_order:  1, sphinx_attr: 'timestamp'
  FieldOrderToSphinxAttr.create! field_order:  2, sphinx_attr: 'host_id'
  FieldOrderToSphinxAttr.create! field_order:  3, sphinx_attr: 'program_id'
  # note: data_source is the same as class, and the sentinel will look up
  #       the classes.class (name) to get the class_id
  FieldOrderToSphinxAttr.create! field_order:  4, sphinx_attr: 'class_id'
  FieldOrderToSphinxAttr.create! field_order:  5, sphinx_attr: 'i0'
  FieldOrderToSphinxAttr.create! field_order:  6, sphinx_attr: 'i1'
  FieldOrderToSphinxAttr.create! field_order:  7, sphinx_attr: 'i2'
  FieldOrderToSphinxAttr.create! field_order:  8, sphinx_attr: 'i3'
  FieldOrderToSphinxAttr.create! field_order:  9, sphinx_attr: 'i4'
  FieldOrderToSphinxAttr.create! field_order: 10, sphinx_attr: 'i5'
  FieldOrderToSphinxAttr.create! field_order: 11, sphinx_attr: 's0'
  FieldOrderToSphinxAttr.create! field_order: 12, sphinx_attr: 's1'
  FieldOrderToSphinxAttr.create! field_order: 13, sphinx_attr: 's2'
  FieldOrderToSphinxAttr.create! field_order: 14, sphinx_attr: 's3'
  FieldOrderToSphinxAttr.create! field_order: 15, sphinx_attr: 's4'
  FieldOrderToSphinxAttr.create! field_order: 16, sphinx_attr: 's5'
end

found = DataPatternType.where(pattern: 'NONE').first
unless found
  DataPatternType.create! pattern: 'NONE'
  DataPatternType.create! pattern: 'QSTRING'
  DataPatternType.create! pattern: 'ESTRING'
  DataPatternType.create! pattern: 'STRING'
  DataPatternType.create! pattern: 'DOUBLE'
  DataPatternType.create! pattern: 'NUMBER'
  DataPatternType.create! pattern: 'IPv4'
  DataPatternType.create! pattern: 'PCRE-IPv4'
end

found = DataFieldType.where(field_type: 'int').first
unless found
  DataFieldType.create! field_type: 'int'
  DataFieldType.create! field_type: 'string'
end

found = DataFieldOperator.where(operator: '<=').first
unless found
  DataFieldOperator.create! operator: '='
  DataFieldOperator.create! operator: '!='
  DataFieldOperator.create! operator: '>='
  DataFieldOperator.create! operator: '<='
end

ds = ['Any',
      'None',
      'Firewall Access Deny',
      'Firewall Connection End',
      'Windows',
      'URL',
      'Snort',
      'SSH Login',
      'SSH Access Deny',
      'SSH Logout',
      'Bro DNS',
      'Bro Notice',
      'Bro SMTP',
      'Bro SMTP Entities',
      'Bro SSL',
      'Bro HTTP',
      'Bro Conn'
].sort
found = DataSource.count > 0
unless found
  ds.each do |name|
    DataSource.create! name: name
  end
end

found = DataSourceField.count > 0
unless found
  # fotsa = FieldOrderToSphinxAttr.select('field_order, sphinx_attr').order(field_order: :asc).all.index_by(&:field_order)
  fields = [
  ['ANY',0,'logtext','string','',''],
  ['ANY',1,'timestamp','int','',''],
  ['ANY',2,'host','int',"IPv4",''],
  ['ANY',3,'program','string','',''],
  ['ANY',4,'source','string','',''],
  ["BRO CONN",5,"srcip","int","IPv4","IPv4"],
  ["BRO CONN",6,"srcport","int","NULL","NUMBER"],
  ["BRO CONN",7,"dstip","int","IPv4","IPv4"],
  ["BRO CONN",8,"dstport","int","NULL","NUMBER"],
  ["BRO CONN",9,"proto","string","NULL","QSTRING"],
  ["BRO DNS",5,"srcip","int","IPv4","IPv4"],
  ["BRO DNS",6,"srcport","int","NULL","NUMBER"],
  ["BRO DNS",7,"dstip","int","IPv4","IPv4"],
  ["BRO DNS",8,"dstport","int","NULL","NUMBER"],
  ["BRO DNS",9,"proto","string","NULL","QSTRING"],
  ["BRO DNS",11,"hostname","string","NULL","QSTRING"],
  ["BRO DNS",12,"answer","string","NULL","QSTRING"],
  ["BRO HTTP",5,"srcip","int","IPv4","IPv4"],
  ["BRO HTTP",6,"srcport","int","NULL","NUMBER"],
  ["BRO HTTP",7,"dstip","int","IPv4","IPv4"],
  ["BRO HTTP",8,"dstport","int","NULL","NUMBER"],
  ["BRO HTTP",9,"status_code","int","NULL","NUMBER"],
  ["BRO HTTP",10,"content_length","int","NULL","NUMBER"],
  ["BRO HTTP",11,"method","string","NULL","QSTRING"],
  ["BRO HTTP",12,"site","string","NULL","QSTRING"],
  ["BRO HTTP",13,"uri","string","NULL","QSTRING"],
  ["BRO HTTP",14,"referer","string","NULL","QSTRING"],
  ["BRO HTTP",15,"user_agent","string","NULL","QSTRING"],
  ["BRO NOTICE",5,"srcip","int","IPv4","IPv4"],
  ["BRO NOTICE",6,"srcport","int","NULL","NUMBER"],
  ["BRO NOTICE",7,"dstip","int","IPv4","IPv4"],
  ["BRO NOTICE",8,"dstport","int","NULL","NUMBER"],
  ["BRO NOTICE",11,"notice_type","string","NULL","QSTRING"],
  ["BRO NOTICE",12,"notice_msg","string","NULL","QSTRING"],
  ["BRO SMTP",5,"srcip","int","IPv4","IPv4"],
  ["BRO SMTP",6,"srcport","int","NULL","NUMBER"],
  ["BRO SMTP",7,"dstip","int","IPv4","IPv4"],
  ["BRO SMTP",8,"dstport","int","NULL","NUMBER"],
  ["BRO SMTP",11,"server","string","NULL","QSTRING"],
  ["BRO SMTP",12,"from","string","NULL","QSTRING"],
  ["BRO SMTP",13,"to","string","NULL","QSTRING"],
  ["BRO SMTP",14,"subject","string","NULL","QSTRING"],
  ["BRO SMTP",15,"last_reply","string","NULL","QSTRING"],
  ["BRO SMTP",16,"path","string","NULL","QSTRING"],
  ["BRO SMTP ENTITIES",5,"srcip","int","IPv4","IPv4"],
  ["BRO SMTP ENTITIES",6,"srcport","int","NULL","NUMBER"],
  ["BRO SMTP ENTITIES",7,"dstip","int","IPv4","IPv4"],
  ["BRO SMTP ENTITIES",8,"dstport","int","NULL","NUMBER"],
  ["BRO SMTP ENTITIES",9,"content_len","int","NULL","NUMBER"],
  ["BRO SMTP ENTITIES",11,"filename","string","NULL","QSTRING"],
  ["BRO SMTP ENTITIES",12,"mime_type","string","NULL","QSTRING"],
  ["BRO SMTP ENTITIES",13,"md5","string","NULL","QSTRING"],
  ["BRO SMTP ENTITIES",14,"extraction_file","string","NULL","QSTRING"],
  ["BRO SMTP ENTITIES",15,"excerpt","string","NULL","QSTRING"],
  ["BRO SSL",5,"srcip","int","IPv4","IPv4"],
  ["BRO SSL",6,"srcport","int","NULL","NUMBER"],
  ["BRO SSL",7,"dstip","int","IPv4","IPv4"],
  ["BRO SSL",8,"dstport","int","NULL","NUMBER"],
  ["BRO SSL",9,"expiration","int","NULL","NUMBER"],
  ["BRO SSL",11,"hostname","string","NULL","QSTRING"],
  ["BRO SSL",12,"subject","string","NULL","QSTRING"],
  ["FIREWALL ACCESS DENY",5,"proto","string","NULL","QSTRING"],
  ["FIREWALL ACCESS DENY",6,"srcip","int","IPv4","IPv4"],
  ["FIREWALL ACCESS DENY",7,"srcport","int","NULL","NUMBER"],
  ["FIREWALL ACCESS DENY",8,"dstip","int","IPv4","IPv4"],
  ["FIREWALL ACCESS DENY",9,"dstport","int","NULL","NUMBER"],
  ["FIREWALL ACCESS DENY",11,"o_int","string","NULL","QSTRING"],
  ["FIREWALL ACCESS DENY",12,"i_int","string","NULL","QSTRING"],
  ["FIREWALL ACCESS DENY",13,"access_group","string","NULL","QSTRING"],
  ["FIREWALL CONNECTION END",5,"proto","string","NULL","QSTRING"],
  ["FIREWALL CONNECTION END",6,"srcip","int","IPv4","IPv4"],
  ["FIREWALL CONNECTION END",7,"srcport","int","NULL","NUMBER"],
  ["FIREWALL CONNECTION END",8,"dstip","int","IPv4","IPv4"],
  ["FIREWALL CONNECTION END",9,"dstport","int","NULL","NUMBER"],
  ["FIREWALL CONNECTION END",10,"conn_bytes","string","NULL","QSTRING"],
  ["FIREWALL CONNECTION END",11,"o_int","string","NULL","QSTRING"],
  ["FIREWALL CONNECTION END",12,"i_int","string","NULL","QSTRING"],
  ["FIREWALL CONNECTION END",13,"conn_duration","string","NULL","QSTRING"],
  ["SNORT",5,"sig_priority","string","NULL","QSTRING"],
  ["SNORT",6,"proto","string","NULL","QSTRING"],
  ["SNORT",7,"srcip","int","IPv4","IPv4"],
  ["SNORT",8,"srcport","int","NULL","NUMBER"],
  ["SNORT",9,"dstip","int","IPv4","IPv4"],
  ["SNORT",10,"dstport","int","NULL","NUMBER"],
  ["SNORT",11,"sig_sid","string","NULL","QSTRING"],
  ["SNORT",12,"sig_msg","string","NULL","QSTRING"],
  ["SNORT",13,"sig_classification","string","NULL","QSTRING"],
  ["SSH ACCESS DENY",5,"port","int","NULL","NUMBER"],
  ["SSH ACCESS DENY",11,"authmethod","string","NULL","QSTRING"],
  ["SSH ACCESS DENY",12,"user","string","NULL","QSTRING"],
  ["SSH ACCESS DENY",13,"device","string","NULL","QSTRING"],
  ["SSH ACCESS DENY",14,"service","string","NULL","QSTRING"],
  ["SSH LOGIN",5,"port","int","NULL","NUMBER"],
  ["SSH LOGIN",11,"authmethod","string","NULL","QSTRING"],
  ["SSH LOGIN",12,"user","string","NULL","QSTRING"],
  ["SSH LOGIN",13,"device","string","NULL","QSTRING"],
  ["SSH LOGIN",14,"service","string","NULL","QSTRING"],
  ["SSH LOGOUT",11,"user","string","NULL","QSTRING"],
  ["URL",5,"srcip","int","IPv4","IPv4"],
  ["URL",6,"dstip","int","IPv4","IPv4"],
  ["URL",7,"status_code","int","NULL","NUMBER"],
  ["URL",8,"content_length","int","NULL","NUMBER"],
  ["URL",9,"country_code","int","NULL","NUMBER"],
  ["URL",11,"method","string","NULL","QSTRING"],
  ["URL",12,"site","string","NULL","QSTRING"],
  ["URL",13,"uri","string","NULL","QSTRING"],
  ["URL",14,"referer","string","NULL","QSTRING"],
  ["URL",15,"user_agent","string","NULL","QSTRING"],
  ["URL",16,"domains","string","NULL","QSTRING"],
  ["WINDOWS",5,"eventid","int","NULL","NUMBER"],
  ["WINDOWS",11,"source","string","NULL","QSTRING"],
  ["WINDOWS",12,"user","string","NULL","QSTRING"],
  ["WINDOWS",13,"field0","string","NULL","QSTRING"],
  ["WINDOWS",14,"type","string","NULL","QSTRING"],
  ["WINDOWS",15,"hostname","string","NULL","QSTRING"],
  ["WINDOWS",16,"category","string","NULL","QSTRING"]
  ]
  fields.each do |field_attrs|
    ds_id = DataSource.where(name: field_attrs[0]).first.id
    ft_id = DataFieldType.where(field_type: field_attrs[3]).first.id
    field_attrs[5] = 'NONE' if field_attrs[5].blank? || field_attrs[5].downcase == 'null'
    pt_id = DataPatternType.where(pattern: field_attrs[5]).first.id
    name = field_attrs[2]
    # san = field_attrs[1] == 0 ? nil : fotsa[field_attrs[1]].sphinx_attr
    if field_attrs[0] == 'ANY'
      san = field_attrs[2]
    else
      case
      when field_attrs[4] == 'IPv4'
        san = field_attrs[2] # don't append the '_l' as we need both '_l' and '_t' in the indexer
        # san = field_attrs[2] + '_l' # ip as a numeric is a long in solr
      when field_attrs[3] == 'int'
        san = field_attrs[2] + '_i'
      else
        san = field_attrs[2] + '_t'
      end
    end
    field_attrs[4] = nil if field_attrs[4].blank? || field_attrs[4].downcase == 'null'
    iv = field_attrs[4]
    pos = field_attrs[1]
    DataSourceField.create! data_source_id: ds_id, data_field_type_id: ft_id, data_pattern_type_id: pt_id, name: name, solr_attr_name: san, input_validation: iv, position: pos
  end
end

Patterndb.dump_source_fields_as_yaml
puts "Note: db/source_fields.yml was created for use with the ruby Kafka consumer and Solr indexer program."

