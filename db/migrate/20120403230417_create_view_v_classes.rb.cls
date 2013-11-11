class CreateViewVClasses < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS v_classes"
    sql = <<-SQL
          CREATE VIEW `v_classes` AS
          SELECT `id` AS id, `class` AS class_name, `parent_id` AS parent_id FROM classes;
          SQL
    execute sql
  end

  def down
  end
end
