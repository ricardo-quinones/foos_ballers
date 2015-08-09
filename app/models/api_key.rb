class ApiKey < ActiveRecord::Base
  belongs_to :player

  validates_uniqueness_of :access_token

  before_create :generate_access_token!

  def inactivate!
    update_attribute(:active, false)
  end

  def encrypted_access_token
    Base64.strict_encode64(access_token.to_s)
  end

  private

  def generate_access_token!
    begin
      self.access_token = SecureRandom::base64(25)
    end while self.class.exists?(access_token: access_token)
  end
end
