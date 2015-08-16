class AddCurrentRatingToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :current_rating_id, :integer
    add_index  :players, :current_rating_id
  end
end
