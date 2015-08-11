class CreateApiKeys < ActiveRecord::Migration
  class Player < ActiveRecord::Base
    has_many :api_keys
  end

  class ApiKey < ActiveRecord::Base
  end

  def up
    create_table :api_keys do |t|
      t.string  :access_token
      t.integer :player_id
      t.boolean :active, default: true

      t.timestamps null: false
    end

    add_index :api_keys, [:access_token, :active], unique: true
    add_index :api_keys, :player_id

    Player.find_each do |p|
      p.api_keys.create(access_token: p.auth_token)
    end
  end

  def down
    drop_table :api_keys
  end
end
