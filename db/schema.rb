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

ActiveRecord::Schema[8.0].define(version: 2025_06_09_000940) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "distributors", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "website_url"
    t.string "country_code", limit: 2
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_distributors_on_active"
    t.index ["country_code"], name: "index_distributors_on_country_code"
    t.index ["name"], name: "index_distributors_on_name", unique: true
  end

  create_table "episodes", force: :cascade do |t|
    t.bigint "tv_show_id", null: false
    t.string "title"
    t.text "summary"
    t.date "air_date"
    t.integer "season_number"
    t.integer "episode_number"
    t.integer "tvmaze_id"
    t.integer "runtime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tv_show_id"], name: "index_episodes_on_tv_show_id"
  end

  create_table "release_dates", force: :cascade do |t|
    t.bigint "tv_show_id", null: false
    t.bigint "distributor_id", null: false
    t.date "release_date", null: false
    t.string "region", null: false
    t.string "release_type"
    t.integer "season_number"
    t.integer "episode_number"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["distributor_id", "release_date"], name: "index_release_dates_on_distributor_id_and_release_date"
    t.index ["distributor_id"], name: "index_release_dates_on_distributor_id"
    t.index ["region", "release_date"], name: "index_release_dates_on_region_and_release_date"
    t.index ["release_date"], name: "index_release_dates_on_release_date"
    t.index ["tv_show_id", "release_date"], name: "index_release_dates_on_tv_show_id_and_release_date"
    t.index ["tv_show_id", "season_number", "episode_number"], name: "index_release_dates_on_show_season_episode"
    t.index ["tv_show_id"], name: "index_release_dates_on_tv_show_id"
  end

  create_table "tv_show_distributors", force: :cascade do |t|
    t.bigint "tv_show_id", null: false
    t.bigint "distributor_id", null: false
    t.string "distribution_type"
    t.string "region"
    t.date "contract_start_date"
    t.date "contract_end_date"
    t.boolean "exclusive", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_end_date"], name: "index_tv_show_distributors_on_contract_end_date"
    t.index ["distributor_id"], name: "index_tv_show_distributors_on_distributor_id"
    t.index ["region"], name: "index_tv_show_distributors_on_region"
    t.index ["tv_show_id", "distributor_id", "region"], name: "index_tv_show_distributors_unique", unique: true
    t.index ["tv_show_id"], name: "index_tv_show_distributors_on_tv_show_id"
  end

  create_table "tv_shows", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "genre"
    t.integer "total_seasons"
    t.integer "total_episodes"
    t.string "status", default: "upcoming"
    t.decimal "imdb_rating", precision: 3, scale: 1
    t.string "language", default: "en"
    t.integer "runtime_minutes"
    t.date "original_air_date"
    t.string "country_of_origin", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tvmaze_id"
    t.date "premiered_at"
    t.string "image_url"
    t.text "summary"
    t.string "network_name"
    t.decimal "rating"
    t.index ["genre"], name: "index_tv_shows_on_genre"
    t.index ["imdb_rating"], name: "index_tv_shows_on_imdb_rating"
    t.index ["language"], name: "index_tv_shows_on_language"
    t.index ["original_air_date"], name: "index_tv_shows_on_original_air_date"
    t.index ["status"], name: "index_tv_shows_on_status"
    t.index ["title"], name: "index_tv_shows_on_title"
  end

  add_foreign_key "episodes", "tv_shows"
  add_foreign_key "release_dates", "distributors"
  add_foreign_key "release_dates", "tv_shows"
  add_foreign_key "tv_show_distributors", "distributors"
  add_foreign_key "tv_show_distributors", "tv_shows"
end
