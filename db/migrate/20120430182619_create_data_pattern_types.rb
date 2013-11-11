class CreateDataPatternTypes < ActiveRecord::Migration
  def change
    create_table :data_pattern_types do |t|
      # enum('NONE', 'QSTRING', 'ESTRING', 'STRING', 'DOUBLE', 'NUMBER', 'IPv4', 'PCRE-IPv4'):
      t.string      :pattern
      t.timestamps
    end
  end
end
