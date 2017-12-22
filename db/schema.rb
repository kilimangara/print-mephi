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

ActiveRecord::Schema.define(version: 20171221232213) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "black_lists", force: :cascade do |t|
    t.integer "chat_id"
    t.string "reason", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.integer "position", null: false
    t.string "name", null: false
    t.boolean "hidden", default: true
    t.integer "parent_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_category_id"], name: "index_categories_on_parent_category_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "phone"
    t.string "name"
    t.integer "chat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bonus_points", default: 0
    t.boolean "action_used", default: false
  end

  create_table "custom_fields", force: :cascade do |t|
    t.string "field_type", null: false
    t.integer "destiny", null: false
    t.boolean "active", default: true
    t.boolean "required", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delivery_variants", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.boolean "active", default: true
    t.integer "price", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "client_id"
    t.string "text", null: false
    t.integer "rate", default: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_feedbacks_on_client_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.string "name", null: false
    t.integer "chat_id"
    t.string "link_to_tg"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "options", force: :cascade do |t|
    t.string "working_time", default: "18:00 - 24:00"
    t.boolean "active", default: true
    t.string "intro", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "action_active", default: false
    t.integer "bonus_points", default: 100
  end

  create_table "order_lines", force: :cascade do |t|
    t.bigint "order_id"
    t.string "name", null: false
    t.integer "price", default: 0
    t.integer "quantity", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_lines_on_order_id"
  end

  create_table "order_values", force: :cascade do |t|
    t.bigint "order_id"
    t.string "field_type", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_values_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "client_id"
    t.integer "total", default: 0
    t.boolean "canceled", default: false
    t.bigint "delivery_variant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fulfilled", default: false
    t.index ["client_id"], name: "index_orders_on_client_id"
    t.index ["delivery_variant_id"], name: "index_orders_on_delivery_variant_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price", default: 0
    t.bigint "category_id"
    t.boolean "hidden", default: true
    t.integer "position", null: false
    t.boolean "has_fixed_price", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "variants", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price", default: 0
    t.bigint "product_id"
    t.boolean "hidden", default: true
    t.boolean "has_fixed_price", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_variants_on_product_id"
  end

end
