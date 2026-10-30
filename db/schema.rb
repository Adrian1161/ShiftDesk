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

ActiveRecord::Schema[8.1].define(version: 2026_10_29_100002) do
  create_table "businesses", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "business_id", null: false
    t.integer "invited_by_id", null: false
    t.string "email", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_invitations_on_business_id"
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "business_id", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_memberships_on_business_id"
    t.index ["user_id", "business_id"], name: "index_memberships_on_user_id_and_business_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "schedule_weeks", force: :cascade do |t|
    t.integer "business_id", null: false
    t.date "week_start", null: false
    t.string "status", default: "draft", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id", "week_start"], name: "index_schedule_weeks_on_business_id_and_week_start", unique: true
    t.index ["business_id"], name: "index_schedule_weeks_on_business_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.integer "schedule_week_id", null: false
    t.integer "membership_id"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_shifts_on_membership_id"
    t.index ["schedule_week_id"], name: "index_shifts_on_schedule_week_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "invitations", "businesses"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "memberships", "businesses"
  add_foreign_key "memberships", "users"
  add_foreign_key "schedule_weeks", "businesses"
  add_foreign_key "shifts", "memberships"
  add_foreign_key "shifts", "schedule_weeks"
end
