class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer :player_1_id
      t.integer :player_2_id

      t.timestamps null: false
    end

    add_index :teams, :player_1_id
    add_index :teams, :player_2_id
  end
end
