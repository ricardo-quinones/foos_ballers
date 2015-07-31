class Player < ActiveRecord::Base
  has_many :teams_as_player_1, class_name: 'Team', foreign_key: :player_1_id
  has_many :teams_as_player_2, class_name: 'Team', foreign_key: :player_2_id
  has_many :matches_as_player_1_on_team_1, through: :teams_as_player_1, source: :matches_as_team_1
  has_many :matches_as_player_1_on_team_2, through: :teams_as_player_1, source: :matches_as_team_2
  has_many :matches_as_player_2_on_team_1, through: :teams_as_player_2, source: :matches_as_team_1
  has_many :matches_as_player_2_on_team_2, through: :teams_as_player_2, source: :matches_as_team_2

  class << self
    def game_stats
      select(:id).
      select(:name).
      select('COUNT(m1.id) + COUNT(m2.id) + COUNT(m3.id) + COUNT(m4.id) AS games').
      select("SUM(#{build_win_select_statement}) AS games_won").
      joins("LEFT OUTER JOIN teams t1 ON t1.player_1_id = players.id").
      joins("LEFT OUTER JOIN teams t2 ON t2.player_2_id = players.id").
      joins("LEFT OUTER JOIN matches m1 ON m1.team_1_id = t1.id").
      joins("LEFT OUTER JOIN matches m2 ON m2.team_2_id = t1.id").
      joins("LEFT OUTER JOIN matches m3 ON m3.team_1_id = t2.id").
      joins("LEFT OUTER JOIN matches m4 ON m4.team_2_id = t2.id").
      group(:id).
      order('games_won DESC')
    end

    private

    def build_win_select_statement
      %w(m1.team_1_id m2.team_2_id m3.team_1_id m4.team_2_id).map.with_index(1) do |s, i|
        "(CASE WHEN #{s} = m#{i}.winner_id THEN 1 ELSE 0 END)"
      end.join(' + ')
    end
  end

  def teams
    Team.where("player_1_id = :p_id OR player_2_id = :p_id", p_id: id)
  end

  def wins
    Match
      .joins(:winner)
      .where("teams.player_1_id = :p_id OR teams.player_2_id = :p_id", p_id: id)
  end

  def matches
    Match
      .joins("LEFT OUTER JOIN teams t1 ON t1.id = matches.team_1_id")
      .joins("LEFT OUTER JOIN teams t2 ON t2.id = matches.team_2_id")
      .where("t1.player_1_id = :p_id OR t1.player_2_id = :p_id OR t2.player_1_id = :p_id OR t2.player_2_id = :p_id", p_id: id)
      .uniq
  end

  def losses
    matches - wins
  end
end
