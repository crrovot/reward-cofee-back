class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :user_rut, null: false
      t.string :notification_type, null: false # reward_available, new_stamp, promo
      t.string :title, null: false
      t.text :message
      t.boolean :read, default: false

      t.timestamps
    end

    add_index :notifications, :user_rut
    add_index :notifications, :read
    add_index :notifications, [:user_rut, :read]
  end
end
