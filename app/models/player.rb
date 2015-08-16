class Player < ActiveRecord::Base
  has_secure_password
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :team_members
  has_many :teams,              through: :team_members, source: :team
  has_many :match_participants, through: :teams,        source: :match_participants
  has_many :matches,            through: :teams,        source: :matches
  has_many :wins,               through: :teams,        source: :wins
  has_many :api_keys
  has_many :ratings

  belongs_to :current_rating, class_name: 'Rating'

  validates_uniqueness_of :email
  validates_presence_of   :email
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }

  before_create :build_new_api_key, :bankify_name

  class << self
    def game_stats
      select(:id).
      select(:name).
      select('COUNT(matches.id) AS games').
      select("SUM(CASE WHEN mp1.id = matches.winner_id THEN 1 ELSE 0 END) AS games_won").
      select("COALESCE(SUM(mp1.goals), 0) AS goals_scored").
      select("COALESCE(SUM(mp2.goals), 0) AS goals_allowed").
      select("COALESCE(ratings.value, 0) as rating").
      joins('LEFT JOIN "team_members" ON "team_members"."player_id" = "players"."id"').
      joins('LEFT JOIN "teams" ON "teams"."id" = "team_members"."team_id"').
      joins('LEFT JOIN "match_participants" mp1 ON "mp1"."team_id" = "teams"."id"').
      joins('LEFT JOIN "matches" ON "matches"."id" = "mp1"."match_id"').
      joins('LEFT JOIN "match_participants" mp2 ON "mp2"."match_id" = "matches"."id" AND "mp2"."id" != "mp1"."id"').
      joins('LEFT JOIN "ratings" ON "ratings"."id" = "players"."current_rating_id"').
      group([:id, '"ratings"."value"']).
      order('games_won DESC')
    end
  end

  def losses
    matches.where.not(winner_id: nil) - wins
  end

  def inactivate_api_key!(api_key)
    api_key.inactivate!
  end

  def stats
    self.class.game_stats.where(id: id)[0]
  end

  def get_first_unfinished_match
    matches.includes(:players).unfinished.order('matches.id ASC').first
  end

  def first_active_encrypted_access_token
    api_keys.first.encrypted_access_token
  end

  def generate_new_api_key!
    api_keys.create!(access_token: ApiKey.generate_access_token!)
  end

  def set_current_rating(mean, deviation, match)
    self.current_rating = ratings.build do |r|
      r.value               = RatingService.rating(mean, deviation)
      r.trueskill_mean      = mean
      r.trueskill_deviation = deviation
      r.previous_rating     = current_rating
      r.match               = match
    end
  end

  def set_current_rating!(mean, deviation, match)
    set_current_rating(mean, deviation, match)
    save!
  end

  private

  def build_new_api_key
    api_keys.build
  end

  def bankify_name
    self.name = name + " Bank"
  end
end
