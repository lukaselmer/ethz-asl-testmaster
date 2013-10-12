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

ActiveRecord::Schema.define(version: 20131011223833) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "machine_configs", force: true do |t|
    t.string   "name"
    t.text     "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "machines", force: true do |t|
    t.string   "test_state"
    t.string   "ip_address"
    t.string   "owner_id"
    t.datetime "launch_time"
    t.string   "instance_type"
    t.string   "instance_id"
    t.string   "dns_name"
    t.string   "status"
    t.string   "availability_zone"
    t.string   "user_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scenarios", force: true do |t|
    t.string   "name"
    t.integer  "execution_multiplicity"
    t.text     "config_template"
    t.integer  "test_run_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scenarios", ["test_run_id"], name: "index_scenarios_on_test_run_id", using: :btree

  create_table "test_run_logs", force: true do |t|
    t.datetime "logged_at"
    t.string   "message_type"
    t.text     "message_content"
    t.integer  "execution_in_microseconds"
    t.integer  "test_run_id"
    t.integer  "test_machine_config_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "test_run_logs", ["test_machine_config_id"], name: "index_test_run_logs_on_test_machine_config_id", using: :btree
  add_index "test_run_logs", ["test_run_id"], name: "index_test_run_logs_on_test_run_id", using: :btree

  create_table "test_runs", force: true do |t|
    t.string   "name"
    t.text     "config"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
