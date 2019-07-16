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

ActiveRecord::Schema.define(version: 2019_07_16_114335) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "job_logs", force: :cascade do |t|
    t.string "message"
    t.integer "severity"
    t.bigint "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_logs_on_job_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.datetime "started_at"
    t.string "name"
    t.string "jid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed"
  end

  create_table "status", force: :cascade do |t|
    t.boolean "importing"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "artist"
    t.string "album"
    t.string "name"
    t.datetime "listened_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
