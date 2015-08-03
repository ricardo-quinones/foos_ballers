class AddAuthenticationFieldsToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :password_digest, :string
    add_index  :players, :email, unique: true
  end
end
