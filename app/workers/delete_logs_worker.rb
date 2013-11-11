require 'rsolr'

class DeleteLogsWorker
  def self.perform(ignore_this)
    start_time = Time.now.utc
    puts "#{start_time.strftime("%Y-%m-%dT%H:%M:%SZ")} DeleteLogsWorker:perform ..."
    begin
      solr = RSolr.connect(url: 'http://127.0.0.1:8983/solr/collection1', retry_503: 2, retry_after_limit: 1)
      solr.delete_by_query 'timestamp:[* TO NOW-8DAYS]'
      solr.commit
    rescue Exception => e
      puts "\tError: RSolr: \n\t#{e.inspect}"
    end
    puts "\telapsed: #{Time.now.utc - start_time} secs"
  end
end