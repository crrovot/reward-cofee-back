class CreatePurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :purchases do |t|
      t.string :user_rut, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :points_earned, default: 0, null: false
      t.json :products
      t.timestamps
    end

    add_index :purchases, :user_rut
    add_index :purchases, :created_at
    add_foreign_key :purchases, :users, column: :user_rut, primary_key: :rut
    
    # Agregar total_points a users si no existe
    add_column :users, :total_points, :integer, default: 0, null: false unless column_exists?(:users, :total_points)
  end
end
