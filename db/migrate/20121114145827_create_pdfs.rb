class CreatePdfs < ActiveRecord::Migration
  def change
    create_table :pdfs do |t|
      t.references  :user
      t.references  :report
      t.string      :path_to_file
      t.string      :file_name
      t.string      :run_status, default: 'running'
      t.datetime    :last_run
      t.timestamps
    end
  end
end
