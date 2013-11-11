class CreateSearchTypes < ActiveRecord::Migration
  def change
    create_table :search_types do |t|
      t.string      :usage_name # search, chart, logcaster
      t.timestamps
    end
  end
end
