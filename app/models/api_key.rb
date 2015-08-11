class ApiKey < ActiveRecord::Base
  belongs_to :player

  validates_uniqueness_of :access_token

  before_create :generate_access_token!

  def self.generate_access_token!
    begin
      access_token = SecureRandom::base64(25)
    end while exists?(access_token: access_token)

    access_token
  end

  def inactivate!
    update_attribute(:active, false)
  end

  def encrypted_access_token
    Base64.strict_encode64(access_token.to_s)
  end

  private

  def generate_access_token!
    self.access_token ||= ApiKey.generate_access_token!
  end
end
