class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :team_members do |t|
      t.integer :player_id
      t.integer :team_id

      t.timestamps null: false
    end

    add_index :team_members, :player_id
    add_index :team_members, :team_id
  end
end
