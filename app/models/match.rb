class Match < ActiveRecord::Base
  has_many :match_participants
  has_many :teams,   through: :match_participants, source: :team
  has_many :players, through: :teams,              source: :players
  has_many :ratings

  belongs_to :winner, class_name: 'MatchParticipant'

  accepts_nested_attributes_for :match_participants

  def self.unfinished
    where(winner_id: nil)
  end

  # @param nested_attributes_hash [Hash] nested attributes hash to update the scores of the match participants and declare a winner
  #
  # Sample hash looks like:
  # {
  #   match_participants_attributes: [
  #     { id: match.match_participants.first.id, goals: 10 }, # The winner
  #     { id: match.match_participants.first.id, goals: 8 }
  #   ]
  # }
  def post_score!(nested_attributes_hash)
    nested_attributes_hash = nested_attributes_hash.with_indifferent_access
    winner_id = nested_attributes_hash[:match_participants_attributes].sort do |a, b|
      b[:goals].to_i <=> a[:goals].to_i
    end.first[:id]

    Match.transaction do
      RatingService.update_ratings(self, winner_id, nested_attributes_hash)
      update_attributes(nested_attributes_hash.merge(winner_id: winner_id))
    end
  end

  def reset!
    Match.transaction do
      players.each do |p|
        rating_to_destroy = p.current_rating
        p.current_rating = p.current_rating.previous_rating
        rating_to_destroy.destroy
        p.save!
      end

      match_participants.first.goals = 0
      match_participants.last.goals  = 0

      match_participants.first.save!
      match_participants.last.save!

      self.winner = nil
      save!
    end
  end
end
