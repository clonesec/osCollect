class CreateHosts < ActiveRecord::Migration
  def change
    create_table :hosts do |t|
      t.integer     :host_ip, limit: 8
      t.string      :host
      t.string      :hostname
      t.timestamps
    end
    add_index :hosts, :host_ip
  end
end
