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

ActiveRecord::Schema[8.0].define(version: 2025_05_20_151433) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "currencies", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.integer "precision"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfers", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "sender_wallet_id", null: false
    t.bigint "recepient_wallet_id", null: false
    t.bigint "currency_id", null: false
    t.integer "amount", null: false
    t.string "transfer_type", null: false
    t.string "state", default: "created", null: false
    t.datetime "execution_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_transfers_on_currency_id"
    t.index ["recepient_wallet_id"], name: "index_transfers_on_recepient_wallet_id"
    t.index ["sender_wallet_id"], name: "index_transfers_on_sender_wallet_id"
  end

  create_table "users", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wallets", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "currency_id", null: false
    t.bigint "user_id", null: false
    t.integer "amount", default: 0, null: false
    t.integer "reserve_amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_wallets_on_currency_id"
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end
end
