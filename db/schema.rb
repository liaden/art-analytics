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

ActiveRecord::Schema.define(version: 20160606140205) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artworks", force: :cascade do |t|
    t.string   "name"
    t.jsonb    "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.date     "started_at"
    t.date     "ended_at"
    t.jsonb    "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "merchandise_sales", force: :cascade do |t|
    t.integer "merchandise_id"
    t.integer "sale_id"
  end

  create_table "merchandises", force: :cascade do |t|
    t.integer  "artwork_id"
    t.string   "name"
    t.jsonb    "tags"
    t.date     "released_on"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "sales", force: :cascade do |t|
    t.integer  "sale_price"
    t.integer  "list_price"
    t.date     "sold_on"
    t.jsonb    "tags"
    t.text     "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "event_id"
  end

end
