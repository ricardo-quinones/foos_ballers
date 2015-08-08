class AddDefaultValueToGoals < ActiveRecord::Migration
  def up
    change_column_default :match_participants, :goals, 0
  end

  def down
    change_column_default :match_participants, :goals, nil
  end
end
