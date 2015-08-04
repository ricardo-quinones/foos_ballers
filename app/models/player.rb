class Player < ActiveRecord::Base
  has_secure_password
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :team_members
  has_many :teams,   through: :team_members, source: :team
  has_many :matches, through: :teams,        source: :matches
  has_many :wins,    through: :teams,        source: :wins

  validates_uniqueness_of :auth_token, :email
  validates_presence_of :email
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  before_create :generate_authentication_token!

  class << self
    def game_stats
      select(:id).
      select(:name).
      select('COUNT(matches.id) AS games').
      select("SUM(CASE WHEN match_participants.id = matches.winner_id THEN 1 ELSE 0 END) AS games_won").
      joins(:matches).
      group(:id).
      order('games_won DESC')
    end
  end

  def losses
    matches - wins
  end

  def reset_authentication_token!
    generate_authentication_token!
    save!
  end

  def encrypted_auth_token
    Base64.strict_encode64(auth_token.to_s)
  end

  def stats
    self.class.game_stats.where(id: id)[0]
  end

  private

  def generate_authentication_token!
    begin
      self.auth_token = SecureRandom::base64(25)
    end while self.class.exists?(auth_token: auth_token)
  end
end
