class Team < ActiveRecord::Base
  has_many :team_members
  has_many :players, -> { uniq }, through: :team_members,       source: :player
  has_many :match_participants
  has_many :matches, -> { uniq }, through: :match_participants, source: :match
  has_many :wins, -> { where("match_participants.id = matches.winner_id").uniq }, through: :match_participants, source: :match

  class << self
    def game_stats
      select(:id).
      select('array_agg(distinct players.name) as player_names').
      select('COUNT(distinct matches.id) AS games').
      select("SUM(CASE WHEN mp1.id = matches.winner_id THEN 1 ELSE 0 END) / 2 AS games_won").
      select("SUM(mp1.goals) AS goals_scored").
      select("SUM(mp2.goals) AS goals_allowed").
      joins('LEFT JOIN "match_participants" mp1 ON "mp1"."team_id" = "teams"."id"').
      joins('LEFT JOIN "matches" ON "matches"."id" = "mp1"."match_id"').
      joins('LEFT JOIN "match_participants" mp2 ON "mp2"."match_id" = "matches"."id" AND "mp2"."id" != "mp1"."id"').
      joins(:players).
      group(:id)
    end

    # This method will check if the team exists and will return the id of that team.
    # Useful for checking if a team should be created before creating a match.
    #
    # @param player_ids [Array] an array of player
    # @return [Team] the team for that array of player ids
    def find_team(player_ids)
      hash_count  = TeamMember.
                      where(player_id: player_ids).
                      group(:team_id).
                      having('COUNT(player_id) > ?', player_ids.length - 1).
                      count

      return unless hash_count.present?
      find_by(id: hash_count.keys.first)
    end
  end

  def stats
    self.class.game_stats.where(id: id)[0]
  end

  def losses
    matches - wins
  end
end
