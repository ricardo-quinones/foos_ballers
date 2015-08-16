class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer    :value
      t.float      :trueskill_mean
      t.float      :trueskill_deviation
      t.integer    :previous_rating_id
      t.references :player, index: true, foreign_key: true, null: false
      t.references :match,  index: true, foreign_key: true, null: false

      t.timestamps null: false
    end

    add_index :ratings, :previous_rating_id
  end
end
