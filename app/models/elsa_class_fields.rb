class ElsaClassFields
  # since we using patterndb.xml from elsa for syslog-ng let's get the
  # classifications/fields from the syslog database:
  # cls: use this class via "rails c"(console): ElsaClassFields.fields, and 
  #      it will create 2 yaml files which can be loaded by kafka consumers
  #      to process the incoming logs produced by syslog-ng
  # note: be sure to change config/database.yml as follows, or wherever syslog is located:
  #       database: syslog
  #       username: root
  #       password: somedog
  #       host: 192.168.1.149

  # ********************************************************************
  # see the model syslogng_patterndb_fields for a version that uses 
  # the oscollect db and works in db/seeds.rb using "be rake db:seed"
  # ********************************************************************
  
  attr_reader :sources, :fields

  def self.fields
    sql = "SELECT DISTINCT sources.id AS id, sources.class AS source, " +
          "fields.field AS name, fields.field_type AS type, fields.input_validation AS iv, " +
          "fcm.field_order AS position " +
          "FROM syslog.fields AS fields " +
          "JOIN syslog.fields_classes_map AS fcm ON (fields.id = fcm.field_id) " +
          "JOIN syslog.classes AS sources ON (fcm.class_id = sources.id) " +
          "ORDER BY id ASC, position ASC"
    @sources = {}
    @fields = {}
    ActiveRecord::Base.connection.execute(sql).each do |f|
      puts f.inspect
      id = f[0]
      unless @sources.has_key?(id)
        @sources[id] = {}
        @sources[id] = f[1].downcase
        @fields[id] = {}
      end
      @fields[id][f[5]] = {name: f[2], type: f[3], iv: f[4], pos: f[5]}
    end
    File.open('elsa_sources.yml', 'wb') { |f| f.write(YAML.dump(@sources)) }
    File.open('elsa_fields.yml', 'wb') { |f| f.write(YAML.dump(@fields)) }
    return @sources, @fields
  end

  def self.load_sources
    @sources = YAML.load(File.read('elsa_sources.yml'))
    return @sources
  end

  def self.load_fields
    @fields = YAML.load(File.read('elsa_fields.yml'))
    return @fields
  end
end
