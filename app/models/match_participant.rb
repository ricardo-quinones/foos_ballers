class MatchParticipant < ActiveRecord::Base
  belongs_to :team
  belongs_to :match
  has_many   :players, through: :team, source: :players
end
