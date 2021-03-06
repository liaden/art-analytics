# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_02_142111) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artworks", id: :serial, force: :cascade do |t|
    t.string "name"
    t.jsonb "tags", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "import_id"
    t.integer "replaced_by_id"
  end

  create_table "dimensions", force: :cascade do |t|
    t.decimal "width", null: false
    t.decimal "height", null: false
    t.decimal "thickness", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["width", "height", "thickness"], name: "index_dimensions_on_width_and_height_and_thickness", unique: true
  end

  create_table "event_inventory_items", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.integer "merchandise_id"
    t.index ["event_id", "merchandise_id"], name: "index_event_inventory_items_on_event_id_and_merchandise_id", unique: true
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name"
    t.date "started_at"
    t.date "ended_at"
    t.jsonb "tags", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "import_id"
    t.string "full_name"
    t.index ["full_name"], name: "index_events_on_full_name", unique: true
  end

  create_table "imports", id: :serial, force: :cascade do |t|
    t.text "note"
    t.text "import_file_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "merchandise_sales", id: :serial, force: :cascade do |t|
    t.integer "merchandise_id"
    t.integer "sale_id"
    t.integer "quantity", default: 1
    t.index ["sale_id", "merchandise_id"], name: "index_merchandise_sales_on_sale_id_and_merchandise_id", unique: true
  end

  create_table "merchandises", id: :serial, force: :cascade do |t|
    t.integer "artwork_id"
    t.string "name"
    t.jsonb "tags", default: [], null: false
    t.date "released_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "import_id"
    t.boolean "unknown_item", default: false
    t.integer "replaced_by_id"
    t.integer "dimension_id"
  end

  create_table "sales", id: :serial, force: :cascade do |t|
    t.integer "list_price"
    t.jsonb "tags", default: [], null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_id"
    t.integer "sale_price_cents", default: 0, null: false
    t.datetime "sold_at"
    t.string "third_party_transaction_id"
  end

  add_foreign_key "artworks", "artworks", column: "replaced_by_id"
  add_foreign_key "artworks", "imports"
  add_foreign_key "event_inventory_items", "events"
  add_foreign_key "event_inventory_items", "merchandises"
  add_foreign_key "events", "imports"
  add_foreign_key "merchandise_sales", "merchandises"
  add_foreign_key "merchandise_sales", "sales"
  add_foreign_key "merchandises", "artworks"
  add_foreign_key "merchandises", "imports"
  add_foreign_key "merchandises", "merchandises", column: "replaced_by_id"
  add_foreign_key "sales", "events"
  create_trigger("events_before_insert_row_tr", :generated => true, :compatibility => 1).
      on("events").
      before(:insert) do
    "NEW.full_name :=  NEW.name || '-' || EXTRACT(year from NEW.started_at);"
  end

  create_trigger("events_before_update_of_name_started_at_row_tr", :generated => true, :compatibility => 1).
      on("events").
      before(:update).
      of(:name, :started_at) do
    "NEW.full_name :=  NEW.name || '-' || EXTRACT(year from NEW.started_at);"
  end

end
