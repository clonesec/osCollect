class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.references  :dashboard
      t.references  :chart
      t.integer     :position
      # note: this is a relative position number within the 3 assumed columns:
      #   row 1: 1=left, 2=middle, 3=right
      #   row 2: 4=left, 5=middle, 6=right ... and so on:
      # note: if a user shrinks the width of their browser then it's
      #       possible for only 2 columns to be displayed or even just
      #       1 column, as twitter bootstrap is responsive/adjusts.
      t.timestamps
    end
    add_index :widgets, :dashboard_id
    add_index :widgets, :chart_id
    # ensure deprecated dashboard_panels table is deleted:
    if ActiveRecord::Base.connection.table_exists?(:dashboard_panels)
      drop_table :dashboard_panels
    end
  end
end
