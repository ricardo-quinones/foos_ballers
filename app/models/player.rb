class Player < ActiveRecord::Base
  has_secure_password
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :teams_as_player_1, class_name: 'Team', foreign_key: :player_1_id
  has_many :teams_as_player_2, class_name: 'Team', foreign_key: :player_2_id
  has_many :matches_as_player_1_on_team_1, through: :teams_as_player_1, source: :matches_as_team_1
  has_many :matches_as_player_1_on_team_2, through: :teams_as_player_1, source: :matches_as_team_2
  has_many :matches_as_player_2_on_team_1, through: :teams_as_player_2, source: :matches_as_team_1
  has_many :matches_as_player_2_on_team_2, through: :teams_as_player_2, source: :matches_as_team_2

  validates_uniqueness_of :auth_token
  validates_presence_of :email
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  before_create :generate_authentication_token!

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
