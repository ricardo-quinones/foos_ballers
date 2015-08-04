class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :winner_id
      t.timestamps null: false
    end

    add_index :matches, :winner_id
  end
end
