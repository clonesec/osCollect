class Patterndb
  # since we are using patterndb.xml from elsa for syslog-ng let's get the
  # classifications/fields from the oscollect database, and use it in
  # db/seeds.rb via "be rake db:seed"
  
  # TODO add column to oscollect.data_sources table to match patterndb.xml id's
  
  attr_reader :source_fields

  PATTERNDB_RULE_IDS = {
    "any"                     => 0,
    "firewall access deny"    => 2,
    "firewall connection end" => 3,
    "windows"                 => 4,
    "url"                     => 7,
    "snort"                   => 8,
    "ssh login"               => 11,
    "ssh access deny"         => 12,
    "ssh logout"              => 13,
    "bro dns"                 => 14,
    "bro notice"              => 15,
    "bro smtp"                => 16,
    "bro smtp entities"       => 17,
    "bro ssl"                 => 18,
    "bro http"                => 19,
    "bro conn"                => 20
  }

  def self.dump_source_fields_as_yaml
    @source_fields = {}
    DataSource.order(name: :asc).each do |ds|
      source = ds.name.downcase
      dynamic_fields = {}
      DataSourceField.select('data_source_id, position, name, solr_attr_name, input_validation')
                     .order(data_source_id: :asc, position: :asc)
                     .where(data_source_id: ds.id)
                     .each do |dsf|
        # puts "#{dsf.data_source_id} \t #{source} \t #{dsf.position} \t #{dsf.name}"
        dynamic_fields[dsf.position] = {
          source: source, 
          name: dsf.name, 
          solr_name: source == 'any' ? dsf.solr_attr_name : "#{source.gsub(' ', '_')}_#{dsf.solr_attr_name}", 
          ip: dsf.input_validation
        }
      end
      @source_fields[PATTERNDB_RULE_IDS[source]] = dynamic_fields
    end
    # puts '_'*150
    # puts @source_fields.to_yaml
    # puts '_'*150
    # puts @source_fields[16].to_yaml
    File.open('db/source_fields.yml', 'wb') { |f| f.write(YAML.dump(@source_fields)) }
  end

  def self.load_source_fields
    @source_fields = YAML.load(File.read('db/source_fields.yml'))
    return @source_fields
  end
end
