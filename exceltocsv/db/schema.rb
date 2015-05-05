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

ActiveRecord::Schema.define(version: 20150505084904) do

  create_table "attendances", force: :cascade do |t|
    t.date     "attendance_date"
    t.time     "time_in"
    t.time     "time_out"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "employee_id"
  end

  add_index "attendances", ["employee_id", "attendance_date"], name: "by_employee_and_date_attendance"

  create_table "employees", force: :cascade do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "department"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "biometrics_id"
    t.string   "falco_id"
    t.boolean  "is_manager"
  end

  add_index "employees", ["biometrics_id"], name: "by_biometrics_id"
  add_index "employees", ["falco_id"], name: "by_falco_id"

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date     "date_start"
    t.date     "date_end"
  end

  create_table "requests", force: :cascade do |t|
    t.date     "date"
    t.time     "ut_time"
    t.decimal  "vacation_leave"
    t.decimal  "sick_leave"
    t.text     "remarks"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "employee_id"
    t.time     "ob_departure"
    t.time     "ob_time_start"
    t.time     "ob_time_end"
    t.time     "ob_arrival"
    t.string   "vacation_leave_balance"
    t.string   "sick_leave_balance"
    t.decimal  "regular_ot"
    t.decimal  "rest_or_special_ot"
    t.decimal  "special_on_rest_ot"
    t.decimal  "regular_holiday_ot"
    t.decimal  "regular_on_rest_ot"
  end

  add_index "requests", ["employee_id", "date"], name: "by_employee_and_date_request"

end
