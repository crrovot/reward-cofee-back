class CreateContactMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_messages do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :message, null: false
      t.boolean :read, default: false
      t.boolean :responded, default: false

      t.timestamps
    end

    add_index :contact_messages, :read
    add_index :contact_messages, :email
  end
end
