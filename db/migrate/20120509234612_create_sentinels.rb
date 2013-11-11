class CreateSentinels < ActiveRecord::Migration
  def change
    create_table :sentinels do |t|
      t.references :sentinel_search_type
      t.string      :name
      t.string      :url_protocol
      t.string      :url_domain_ip
      t.integer     :url_port
      t.string      :info_path
      t.string      :info_http_method
      t.string      :browse_path
      t.string      :browse_http_method
      t.string      :search_path
      t.string      :search_http_method
      t.string      :groupby_path
      t.string      :groupby_http_method
      t.integer     :request_timeout
      t.integer     :max_concurrent_requests
      t.timestamps
    end
    add_index :sentinels, :sentinel_search_type_id
  end
end
