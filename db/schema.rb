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

ActiveRecord::Schema[8.1].define(version: 2026_10_23_024050) do
  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "secret_word_id"
    t.string "status", default: "setup", null: false
    t.index ["category_id"], name: "index_games_on_category_id"
    t.index ["secret_word_id"], name: "index_games_on_secret_word_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "game_id", null: false
    t.string "name", null: false
    t.boolean "is_imposter", default: false, null: false
    t.integer "turn_order", null: false
    t.index ["game_id", "turn_order"], name: "index_players_on_game_id_and_turn_order", unique: true
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  create_table "words", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "word", null: false
    t.index ["category_id", "word"], name: "index_words_on_category_id_and_word", unique: true
    t.index ["category_id"], name: "index_words_on_category_id"
  end

  add_foreign_key "games", "categories"
  add_foreign_key "games", "words", column: "secret_word_id"
  add_foreign_key "players", "games"
  add_foreign_key "words", "categories"
end
