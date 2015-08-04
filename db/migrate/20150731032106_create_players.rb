class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string     :name
      t.string     :email
      t.string     :password_digest
      t.string     :auth_token
      t.attachment :avatar

      t.timestamps null: false
    end

    add_index  :players, :email,      unique: true
    add_index  :players, :auth_token, unique: true
  end
end
