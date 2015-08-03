class Api::V1::BaseController < ApplicationController
  rescue_from ApiErrors::ApiStandardError, with: :show_error

  private

  def show_error(e)
    render json: e.as_json, status: e.status
  end

  def get_player
    auth_token = request.headers['HTTP_AUTHORIZATION']
    unless auth_token.nil?
      decrypted_auth_token = Base64.strict_decode64(auth_token)
      @player = Player.find_by(auth_token: decrypted_auth_token)
    end
    raise ApiErrors::AuthTokenNotFoundError unless @player
  end
end