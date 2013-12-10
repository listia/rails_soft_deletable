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

ActiveRecord::Schema.define(version: Time.now.strftime("%Y%m%d%H%M%S")) do
  create_table "decimal_models", force: true do |t|
    t.decimal "deleted_at", default: 0
    t.integer "integer_model_id"
  end

  create_table "integer_models", force: true do |t|
    t.integer "deleted_at", default: 0
  end

  create_table "forests", force: true do |t|
    t.integer "deleted_at", default: 0
  end

  create_table "trees", force: true do |t|
    t.integer "deleted_at", default: 0
    t.integer "forest_id"
    t.integer "park_id"
    t.integer "house_id"
    t.boolean "biggest", default: false
  end

  create_table "parks", force: true do |t|
    t.integer "deleted_at", default: 0
  end

  create_table "houses", force: true do |t|
    t.integer "owner_id"
    t.integer "park_id"
  end

  create_table "owners", force: true do |t|
    t.integer "deleted_at", default: 0
  end

  create_table "windows", force: true do |t|
    t.integer "deleted_at", default: 0
    t.integer "house_id"
    t.boolean "biggest", default: false
  end
end
