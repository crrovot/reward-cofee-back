class CreateRedemptions < ActiveRecord::Migration[7.1]
  def change
    create_table :redemptions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :user_rut, null: false
      t.references :reward, null: false, foreign_key: true
      t.string :redemption_code, null: false
      t.string :status, default: "pending" # pending, used, expired
      t.datetime :used_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :redemptions, :user_rut
    add_index :redemptions, :redemption_code, unique: true
    add_index :redemptions, :status
  end
end
