class Team < ActiveRecord::Base
  belongs_to :player_1, class_name: 'Player'
  belongs_to :player_2, class_name: 'Player'

  has_many :matches_as_team_1, class_name: 'Match', foreign_key: :team_1_id
  has_many :matches_as_team_2, class_name: 'Match', foreign_key: :team_2_id

  has_many :wins, class_name: 'Match', foreign_key: :winner_id

  class << self
    def game_stats
      select('gs.id').
      select('p1.name as first_player').
      select('p2.name as second_player').
      select('gs.games').
      select('gs.games_won').
      from("(#{game_stats_inner_query.to_sql}) gs").
      joins("JOIN players p1 ON p1.id = gs.player_1_id").
      joins("JOIN players p2 ON p2.id = gs.player_2_id")
    end

    private

    def game_stats_inner_query
      select([:id, :player_1_id, :player_2_id]).
      select('COUNT(m1.id) + COUNT(m2.id) AS games').
      select("SUM(#{build_win_select_statement}) AS games_won").
      joins("LEFT OUTER JOIN matches m1 ON m1.team_1_id = teams.id").
      joins("LEFT OUTER JOIN matches m2 ON m2.team_2_id = teams.id").
      group(:id).
      order('games_won DESC')
    end

    def build_win_select_statement
      %w(m1.team_1_id m2.team_2_id).map.with_index(1) do |s, i|
        "(CASE WHEN #{s} = m#{i}.winner_id THEN 1 ELSE 0 END)"
      end.join(' + ')
    end
  end

  def matches
    Match.where("team_1_id = :team_id OR team_2_id = :team_id", team_id: id)
  end

  def losses
    matches - wins
  end
end
