class AlertHistories < ActiveRecord::Migration
  def up
    # this table represents a circular log, similar to a fixed size ring buffer, except
    # the size can be adjusted by changing "5000" to lower or higher number and in time
    # the number of entries in the table will adjust according for details see:
    # http://dt.deviantart.com/journal/Build-Your-Own-Circular-Log-with-MySQL-222550965
    #
    # to add new events:
    #   REPLACE INTO alert_histories
    #   SET row_id = (SELECT COALESCE(MAX(id), 0) % 5000 + 1 FROM alert_histories AS t),
    #       alert_id = 1,
    #       start_time = 0,
    #       end_time = 0,
    #       matches = 0,
    #       elapsed_time = 0;
    execute "
      CREATE TABLE alert_histories (
      id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      alert_id int(11) DEFAULT NULL,
      row_id INTEGER UNSIGNED NOT NULL UNIQUE KEY,
      timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      start_time INTEGER UNSIGNED DEFAULT '0',
      end_time INTEGER UNSIGNED DEFAULT '0',
      matches INTEGER UNSIGNED DEFAULT '0',
      elapsed_time FLOAT DEFAULT '0',
      INDEX (timestamp) );
    "
  end

  def down
  end
end
