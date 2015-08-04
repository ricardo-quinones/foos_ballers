class CreateMatchParticipants < ActiveRecord::Migration
  def change
    create_table :match_participants do |t|
      t.integer :team_id
      t.integer :match_id
      t.integer :goals

      t.timestamps null: false
    end

    add_index :match_participants, :team_id
    add_index :match_participants, :match_id
  end
end
