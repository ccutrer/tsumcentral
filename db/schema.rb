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

ActiveRecord::Schema[7.0].define(version: 2018_01_16_015720) do
  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "paused_until", precision: nil
    t.string "password_digest"
    t.boolean "is_admin", default: false, null: false
    t.boolean "suspended", default: false, null: false
    t.boolean "run_now", default: false, null: false
    t.boolean "extend_timeout", default: false, null: false
    t.index ["name"], name: "index_players_on_name"
  end

  create_table "runs", force: :cascade do |t|
    t.integer "player_id", null: false
    t.datetime "ended_at", precision: nil
    t.integer "hearts_given"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["player_id", "ended_at"], name: "index_runs_on_player_id_and_ended_at"
  end

  add_foreign_key "runs", "players"
end
