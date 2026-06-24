# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_06_24_091441) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "delivery_request_id", null: false
    t.string "pickup_street"
    t.string "pickup_city"
    t.float "pickup_latitude"
    t.float "pickup_longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "delivery_street"
    t.string "delivery_city"
    t.float "delivery_latitude"
    t.float "delivery_longitude"
    t.index ["delivery_request_id"], name: "index_addresses_on_delivery_request_id"
  end

  create_table "delivery_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "delivery_request_id", null: false
    t.string "event_type"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_request_id"], name: "index_delivery_events_on_delivery_request_id"
  end

  create_table "delivery_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "driver_id"
    t.string "package_description"
    t.decimal "weight"
    t.string "status", default: "assigned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_delivery_requests_on_driver_id"
    t.index ["user_id"], name: "index_delivery_requests_on_user_id"
  end

  create_table "driver_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "driver_id", null: false
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_driver_locations_on_driver_id"
  end

  create_table "drivers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.boolean "available"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "addresses", "delivery_requests"
  add_foreign_key "delivery_events", "delivery_requests"
  add_foreign_key "delivery_requests", "drivers"
  add_foreign_key "delivery_requests", "users"
  add_foreign_key "driver_locations", "drivers"
end
