class RemoveAuthTokenFromPlayer < ActiveRecord::Migration
  def up
    remove_column :players, :auth_token
  end

  def down
    add_column :players, :auth_token, :string
    add_index  :players, :auth_token, unique: true
  end
end
