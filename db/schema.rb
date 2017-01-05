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

ActiveRecord::Schema.define(version: 20170105031459) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artworks", force: :cascade do |t|
    t.string   "name"
    t.jsonb    "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "import_id"
  end

  create_table "event_inventory_items", force: :cascade do |t|
    t.integer "event_id"
    t.integer "merchandise_id"
    t.index ["event_id", "merchandise_id"], name: "index_event_inventory_items_on_event_id_and_merchandise_id", unique: true, using: :btree
  end

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.date     "started_at"
    t.date     "ended_at"
    t.jsonb    "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "import_id"
    t.string   "full_name"
    t.index ["full_name"], name: "index_events_on_full_name", unique: true, using: :btree
  end

  create_table "imports", force: :cascade do |t|
    t.text     "note"
    t.text     "import_file_data"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "merchandise_sales", force: :cascade do |t|
    t.integer "merchandise_id"
    t.integer "sale_id"
    t.integer "quantity",       default: 0
  end

  create_table "merchandises", force: :cascade do |t|
    t.integer  "artwork_id"
    t.string   "name"
    t.jsonb    "tags"
    t.date     "released_on"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "import_id"
  end

  create_table "sales", force: :cascade do |t|
    t.integer  "list_price"
    t.date     "sold_on"
    t.jsonb    "tags"
    t.text     "note"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "event_id"
    t.integer  "sale_price_cents", default: 0, null: false
  end

  add_foreign_key "artworks", "imports"
  add_foreign_key "event_inventory_items", "events"
  add_foreign_key "event_inventory_items", "merchandises"
  add_foreign_key "events", "imports"
  add_foreign_key "merchandise_sales", "merchandises"
  add_foreign_key "merchandise_sales", "sales"
  add_foreign_key "merchandises", "artworks"
  add_foreign_key "merchandises", "imports"
  add_foreign_key "sales", "events"
  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute(<<-TRIGGERSQL)
CREATE OR REPLACE FUNCTION public.events_before_insert_row_tr()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.full_name :=  NEW.name || '-' || EXTRACT(year from NEW.started_at);
    RETURN NEW;
END;
$function$
  TRIGGERSQL

  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute("CREATE TRIGGER events_before_insert_row_tr BEFORE INSERT ON \"events\" FOR EACH ROW EXECUTE PROCEDURE events_before_insert_row_tr()")

  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute(<<-TRIGGERSQL)
CREATE OR REPLACE FUNCTION public.events_before_update_of_name_started_at_row_tr()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.full_name :=  NEW.name || '-' || EXTRACT(year from NEW.started_at);
    RETURN NEW;
END;
$function$
  TRIGGERSQL

  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute("CREATE TRIGGER events_before_update_of_name_started_at_row_tr BEFORE UPDATE OF name, started_at ON events FOR EACH ROW EXECUTE PROCEDURE events_before_update_of_name_started_at_row_tr()")

end
