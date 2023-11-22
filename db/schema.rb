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

ActiveRecord::Schema[7.1].define(version: 2023_11_21_214257) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "job_logs", force: :cascade do |t|
    t.string "message"
    t.integer "severity"
    t.bigint "job_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["job_id"], name: "index_job_logs_on_job_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.datetime "started_at", precision: nil
    t.string "name"
    t.string "jid"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "completed", default: false, null: false
  end

  create_table "status", force: :cascade do |t|
    t.boolean "importing", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tracks", force: :cascade do |t|
    t.string "artist"
    t.string "album"
    t.string "name"
    t.datetime "listened_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "url"
    t.string "image_url"
    t.boolean "hidden", default: false, null: false
    t.string "username"
  end

end
