class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :team_1_id
      t.integer :team_2_id
      t.integer :winner_id

      t.timestamps null: false
    end

    add_index :matches, :team_1_id
    add_index :matches, :team_2_id
    add_index :matches, :winner_id
  end
end
