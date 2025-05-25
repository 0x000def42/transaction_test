class CreateTransfers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.timestamps
    end

    create_table :currencies do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :name, null: false
      t.integer :precision
      t.timestamps
    end

    create_table :wallets do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.references :currency, null: false
      t.references :user, null: false
      t.integer :amount, null: false, default: 0
      t.integer :reserve_amount, null: false, default: 0
      t.timestamps

    end

    add_index :wallets, [:currency_id, :user_id], unique: true, name: "transfers_currency_id_user_id_udx"

    create_table :transfers do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.references :sender_wallet, null: false
      t.references :recepient_wallet, null: false
      t.references :currency, null: false
      t.integer :amount, null: false
      t.string :transfer_type, null: false
      t.string :state, null: false, default: "created"
      t.datetime :execute_at
      t.timestamps
    end
  end
end
