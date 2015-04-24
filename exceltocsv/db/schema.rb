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

ActiveRecord::Schema.define(version: 20150424015621) do

  create_table "attendances", force: :cascade do |t|
    t.date     "attendance_date"
    t.time     "time_in"
    t.time     "time_out"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "last_name"
    t.string   "first_name"
  end

  create_table "employees", force: :cascade do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "department"
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.string   "name"
    t.string   "department"
    t.date     "date"
    t.decimal  "ot_hours"
    t.time     "ut_time"
    t.decimal  "vacation_leave"
    t.decimal  "sick_leave"
    t.decimal  "official_business"
    t.text     "remarks"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

end
