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

ActiveRecord::Schema[7.0].define(version: 2024_05_26_083011) do
  create_table "casts", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "film_casts", charset: "utf8", force: :cascade do |t|
    t.bigint "film_id", null: false
    t.bigint "cast_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cast_id"], name: "index_film_casts_on_cast_id"
    t.index ["film_id"], name: "index_film_casts_on_film_id"
  end

  create_table "film_staffs", charset: "utf8", force: :cascade do |t|
    t.bigint "film_id", null: false
    t.bigint "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["film_id"], name: "index_film_staffs_on_film_id"
    t.index ["staff_id"], name: "index_film_staffs_on_staff_id"
  end

  create_table "films", charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "release_year"
    t.string "poster_image_url"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_films_on_title", unique: true
  end

  create_table "staffs", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "role"
    t.string "production"
    t.string "official_site"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8", force: :cascade do |t|
    t.string "nickname", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "film_casts", "casts"
  add_foreign_key "film_casts", "films"
  add_foreign_key "film_staffs", "films"
  add_foreign_key "film_staffs", "staffs"
end
