class AddQrTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :qr_token, :string unless column_exists?(:users, :qr_token)
    add_column :users, :qr_token_expires_at, :datetime unless column_exists?(:users, :qr_token_expires_at)
    add_index :users, :qr_token, unique: true unless index_exists?(:users, :qr_token, unique: true)
  end
end
