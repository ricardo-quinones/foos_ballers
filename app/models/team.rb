class Team < ActiveRecord::Base
  has_many :team_members
  has_many :players, -> { uniq }, through: :team_members,       source: :player
  has_many :match_participants
  has_many :matches, -> { uniq }, through: :match_participants, source: :match
  has_many :wins, -> { where("match_participants.id = matches.winner_id").uniq }, through: :match_participants, source: :match

  class << self
    def game_stats
      select(:id).
      select('array_agg(players.name) as player_names').
      select('COUNT(distinct matches.id) AS games').
      select("SUM(CASE WHEN match_participants.id = matches.winner_id THEN 1 ELSE 0 END) / 2 AS games_won").
      joins(:matches).
      joins(:players).
      group(:id)
    end
  end

  def losses
    matches - wins
  end
end
