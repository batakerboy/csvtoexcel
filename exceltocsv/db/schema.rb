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

ActiveRecord::Schema.define(version: 20150519064552) do

  create_table "attendances", force: :cascade do |t|
    t.date     "attendance_date"
    t.time     "time_in"
    t.time     "time_out"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "employee_id",     limit: 255
  end

  add_index "attendances", ["employee_id", "attendance_date"], name: "by_employee_and_date_attendance", using: :btree

  create_table "employees", force: :cascade do |t|
    t.string   "last_name",     limit: 255
    t.string   "first_name",    limit: 255
    t.string   "department",    limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "biometrics_id", limit: 255
    t.string   "falco_id",      limit: 255
    t.boolean  "is_manager",    limit: 1
  end

  add_index "employees", ["biometrics_id"], name: "by_biometrics_id", using: :btree
  add_index "employees", ["falco_id"], name: "by_falco_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.date     "date_start"
    t.date     "date_end"
    t.string   "name",         limit: 255
    t.string   "employee_ids", limit: 255, default: "--- []\n"
  end

  create_table "requests", force: :cascade do |t|
    t.date     "date"
    t.time     "ut_time"
    t.decimal  "vacation_leave",                       precision: 10
    t.decimal  "sick_leave",                           precision: 10
    t.text     "remarks",                limit: 65535
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "employee_id",            limit: 255
    t.time     "ob_departure"
    t.time     "ob_time_start"
    t.time     "ob_time_end"
    t.time     "ob_arrival"
    t.string   "vacation_leave_balance", limit: 255
    t.string   "sick_leave_balance",     limit: 255
    t.decimal  "regular_ot",                           precision: 10
    t.decimal  "rest_or_special_ot",                   precision: 10
    t.decimal  "special_on_rest_ot",                   precision: 10
    t.decimal  "regular_holiday_ot",                   precision: 10
    t.decimal  "regular_on_rest_ot",                   precision: 10
    t.string   "offset",                 limit: 255
    t.boolean  "is_holiday",             limit: 1
  end

  add_index "requests", ["employee_id", "date"], name: "by_employee_and_date_request", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",           limit: 255
    t.string   "encrypted_password", limit: 255
    t.string   "first_name",         limit: 255
    t.string   "last_name",          limit: 255
    t.string   "department",         limit: 255
    t.string   "salt",               limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "is_admin",           limit: 1
    t.boolean  "is_active",          limit: 1
    t.string   "email",              limit: 255
  end

end
