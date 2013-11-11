class CreateReportSearches < ActiveRecord::Migration
  def change
    create_table :report_searches do |t|
      t.references  :report
      t.references  :search
      t.integer     :position
      t.timestamps
    end
    add_index :report_searches, :report_id
    add_index :report_searches, :search_id
  end
end
