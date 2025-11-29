class CreateRewards < ActiveRecord::Migration[7.1]
  def change
    create_table :rewards do |t|
      t.string :name, null: false
      t.text :description
      t.integer :stamps_required, null: false, default: 10
      t.string :image_url
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :rewards, :active
    add_index :rewards, :stamps_required
  end
end
