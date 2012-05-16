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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120305205526) do

  create_table "commands", :force => true do |t|
    t.string   "cmdline"
    t.string   "result"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "feature_files", :force => true do |t|
    t.string   "name"
    t.integer  "run_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nodes", :force => true do |t|
    t.string   "host"
    t.string   "user"
    t.string   "port"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.boolean  "locked",     :default => false
    t.float    "ping"
    t.string   "display"
    t.string   "last_error"
    t.float    "load15"
    t.float    "load10"
    t.float    "load5"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "folder"
    t.string   "repo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.boolean  "locked",     :default => false
  end

  create_table "runs", :force => true do |t|
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed",    :default => false
    t.datetime "completed_at"
    t.boolean  "started",      :default => false
    t.text     "comment"
  end

  create_table "scenarios", :force => true do |t|
    t.string   "name"
    t.text     "stdout"
    t.text     "log"
    t.integer  "feature_file_id"
    t.integer  "node_id"
    t.boolean  "started",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed",       :default => false
    t.boolean  "succeeded"
    t.boolean  "failed"
    t.integer  "failures",        :default => 0
  end

end
