# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131110191230) do

  create_table "alert_histories", force: true do |t|
    t.integer   "alert_id"
    t.integer   "row_id",                     null: false
    t.timestamp "timestamp",                  null: false
    t.integer   "start_time",   default: 0
    t.integer   "end_time",     default: 0
    t.integer   "matches",      default: 0
    t.float     "elapsed_time", default: 0.0
  end

  add_index "alert_histories", ["row_id"], name: "row_id", unique: true, using: :btree
  add_index "alert_histories", ["timestamp"], name: "timestamp", using: :btree

  create_table "alerts", force: true do |t|
    t.integer  "user_id"
    t.integer  "search_id"
    t.boolean  "active",                 default: true
    t.boolean  "logs_in_email",          default: true
    t.string   "status",                 default: "n"
    t.integer  "last_run",               default: 0
    t.integer  "last_total_matches",     default: 0
    t.integer  "last_status_change",     default: 0
    t.string   "name"
    t.text     "description"
    t.string   "threshold_operator",     default: "gt"
    t.integer  "threshold_count",        default: 0
    t.integer  "threshold_time_seconds", default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "shared"
    t.string   "origin"
  end

  add_index "alerts", ["search_id"], name: "index_alerts_on_search_id", using: :btree
  add_index "alerts", ["user_id"], name: "index_alerts_on_user_id", using: :btree

  create_table "charts", force: true do |t|
    t.integer  "user_id"
    t.integer  "search_id"
    t.string   "name"
    t.string   "chart_type"
    t.string   "chart_title"
    t.text     "chart_json_serialized"
    t.integer  "group_by"
    t.text     "query_params"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "chart_library",         default: "gchart"
    t.string   "shared"
    t.string   "origin"
  end

  add_index "charts", ["search_id"], name: "index_charts_on_search_id", using: :btree
  add_index "charts", ["user_id"], name: "index_charts_on_user_id", using: :btree

  create_table "dashboards", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "shared"
    t.string   "origin"
  end

  add_index "dashboards", ["user_id"], name: "index_dashboards_on_user_id", using: :btree

  create_table "data_field_operators", force: true do |t|
    t.string   "operator"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_field_types", force: true do |t|
    t.string   "field_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_pattern_types", force: true do |t|
    t.string   "pattern"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_source_fields", force: true do |t|
    t.integer  "data_source_id"
    t.integer  "data_field_type_id"
    t.integer  "data_pattern_type_id"
    t.string   "name"
    t.string   "solr_attr_name"
    t.string   "input_validation"
    t.integer  "position"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "data_source_fields", ["data_field_type_id"], name: "index_data_source_fields_on_data_field_type_id", using: :btree
  add_index "data_source_fields", ["data_source_id"], name: "index_data_source_fields_on_data_source_id", using: :btree

  create_table "data_sources", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_order_to_sphinx_attrs", force: true do |t|
    t.integer "field_order"
    t.string  "sphinx_attr"
  end

  create_table "group_excludes", force: true do |t|
    t.integer  "group_id"
    t.string   "ip_range_from"
    t.integer  "ip_range_from_num"
    t.string   "ip_range_to"
    t.integer  "ip_range_to_num"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "group_excludes", ["group_id"], name: "index_group_excludes_on_group_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "host_histories", force: true do |t|
    t.string   "history_type",           default: "weekly"
    t.integer  "host_ip",      limit: 8
    t.string   "host"
    t.integer  "count",        limit: 8, default: 0
    t.integer  "year"
    t.integer  "week"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "host_histories", ["history_type"], name: "index_host_histories_on_history_type", using: :btree
  add_index "host_histories", ["host_ip"], name: "index_host_histories_on_host_ip", using: :btree
  add_index "host_histories", ["year", "week"], name: "index_host_histories_on_year_and_week", using: :btree

  create_table "hosts", force: true do |t|
    t.integer  "host_ip",    limit: 8
    t.string   "host"
    t.string   "hostname"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "hosts", ["host_ip"], name: "index_hosts_on_host_ip", using: :btree

  create_table "logs", force: true do |t|
    t.integer  "user_id"
    t.boolean  "active",      default: true
    t.string   "name"
    t.text     "description"
    t.text     "host_ips"
    t.string   "auto_run_at", default: "both"
    t.integer  "last_run",    default: 0
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "send_email",  default: false
  end

  add_index "logs", ["user_id"], name: "index_logs_on_user_id", using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "role",       default: "user"
    t.integer  "roles_mask"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree

  create_table "pdfs", force: true do |t|
    t.integer  "user_id"
    t.integer  "report_id"
    t.string   "path_to_file"
    t.string   "file_name"
    t.string   "run_status",   default: "running"
    t.datetime "last_run"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "report_charts", force: true do |t|
    t.integer  "report_id"
    t.integer  "chart_id"
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "report_charts", ["chart_id"], name: "index_report_charts_on_chart_id", using: :btree
  add_index "report_charts", ["report_id"], name: "index_report_charts_on_report_id", using: :btree

  create_table "report_histories", force: true do |t|
    t.integer   "report_id"
    t.integer   "row_id",                     null: false
    t.timestamp "timestamp",                  null: false
    t.text      "message"
    t.float     "elapsed_time", default: 0.0
  end

  add_index "report_histories", ["row_id"], name: "row_id", unique: true, using: :btree
  add_index "report_histories", ["timestamp"], name: "timestamp", using: :btree

  create_table "report_searches", force: true do |t|
    t.integer  "report_id"
    t.integer  "search_id"
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "report_searches", ["report_id"], name: "index_report_searches_on_report_id", using: :btree
  add_index "report_searches", ["search_id"], name: "index_report_searches_on_search_id", using: :btree

  create_table "reports", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.boolean  "auto_run",            default: false
    t.datetime "auto_run_last_at"
    t.integer  "auto_run_count",      default: 0
    t.string   "auto_run_at"
    t.integer  "auto_run_daily_hour"
    t.boolean  "include_summary",     default: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "shared"
    t.string   "origin"
  end

  add_index "reports", ["auto_run"], name: "index_reports_on_auto_run", using: :btree
  add_index "reports", ["auto_run_at"], name: "index_reports_on_auto_run_at", using: :btree
  add_index "reports", ["auto_run_daily_hour"], name: "index_reports_on_auto_run_daily_hour", using: :btree
  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "search_fields", force: true do |t|
    t.integer  "search_id"
    t.integer  "data_source_id"
    t.integer  "data_source_field_id"
    t.integer  "data_field_operator_id"
    t.string   "and_or"
    t.text     "match_or_attribute_value"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "search_fields", ["data_field_operator_id"], name: "index_search_fields_on_data_field_operator_id", using: :btree
  add_index "search_fields", ["data_source_field_id"], name: "index_search_fields_on_data_source_field_id", using: :btree
  add_index "search_fields", ["data_source_id"], name: "index_search_fields_on_data_source_id", using: :btree
  add_index "search_fields", ["search_id"], name: "index_search_fields_on_search_id", using: :btree

  create_table "search_types", force: true do |t|
    t.string   "usage_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "searches", force: true do |t|
    t.integer  "user_id"
    t.integer  "search_type_id",     default: 1
    t.string   "name"
    t.text     "query"
    t.text     "sources"
    t.string   "relative_timestamp"
    t.string   "date_from"
    t.string   "time_from"
    t.string   "date_to"
    t.string   "time_to"
    t.string   "host_from"
    t.string   "host_to"
    t.integer  "group_by"
    t.text     "query_params"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "shared"
    t.string   "origin"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "shares", force: true do |t|
    t.integer "user_id"
    t.string  "share_token"
    t.integer "shared_id"
    t.string  "share_type"
  end

  add_index "shares", ["share_token"], name: "index_shares_on_share_token", using: :btree
  add_index "shares", ["user_id"], name: "index_shares_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "search_results_page_size"
    t.integer  "search_id"
    t.boolean  "send_weekly_log_counts",   default: false
    t.integer  "max_search_results"
  end

  create_table "widgets", force: true do |t|
    t.integer  "dashboard_id"
    t.integer  "chart_id"
    t.integer  "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "widgets", ["chart_id"], name: "index_widgets_on_chart_id", using: :btree
  add_index "widgets", ["dashboard_id"], name: "index_widgets_on_dashboard_id", using: :btree

end
