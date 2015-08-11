class Player < ActiveRecord::Base
  has_secure_password
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :team_members
  has_many :teams,   through: :team_members, source: :team
  has_many :matches, through: :teams,        source: :matches
  has_many :wins,    through: :teams,        source: :wins
  has_many :api_keys

  validates_uniqueness_of :email
  validates_presence_of   :email
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }

  before_create :build_new_api_key, :bankify_name

  class << self
    def game_stats
      select(:id).
      select(:name).
      select('COUNT(matches.id) AS games').
      select("SUM(CASE WHEN match_participants.id = matches.winner_id THEN 1 ELSE 0 END) AS games_won").
      joins('LEFT JOIN "team_members" ON "team_members"."player_id" = "players"."id"').
      joins('LEFT JOIN "teams" ON "teams"."id" = "team_members"."team_id"').
      joins('LEFT JOIN "match_participants" ON "match_participants"."team_id" = "teams"."id"').
      joins('LEFT JOIN "matches" ON "matches"."id" = "match_participants"."match_id"').
      group(:id).
      order('games_won DESC')
    end
  end

  def losses
    matches - wins
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

  private

  def build_new_api_key
    api_keys.build
  end

  def bankify_name
    self.name = name + " Bank"
  end
end
