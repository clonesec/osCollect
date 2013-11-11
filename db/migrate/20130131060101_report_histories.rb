class ReportHistories < ActiveRecord::Migration
  def up
    # this table represents a circular log, similar to a fixed size ring buffer, except
    # the size can be adjusted by changing "5000" to lower or higher number and in time
    # the number of entries in the table will adjust according for details see:
    # http://dt.deviantart.com/journal/Build-Your-Own-Circular-Log-with-MySQL-222550965
    #
    # to add new events:
    #   REPLACE INTO report_histories
    #   SET row_id = (SELECT COALESCE(MAX(id), 0) % 5000 + 1 FROM report_histories AS t),
    #       report_id = 1,
    #       message = nil,
    #       elapsed_time = 0;
    execute "
      CREATE TABLE report_histories (
      id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      report_id int(11) DEFAULT NULL,
      row_id INTEGER UNSIGNED NOT NULL UNIQUE KEY,
      timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      message TEXT COLLATE utf8_unicode_ci,
      elapsed_time FLOAT DEFAULT '0',
      INDEX (timestamp) );
    "
  end

  def down
  end
end
