class Api::V1::BaseController < ApplicationController
  rescue_from ApiErrors::ApiStandardError, with: :show_error

  private

  def show_error(e)
    render json: e.as_json, status: e.status
  end

  def get_player
    begin
      access_token = request.headers['HTTP_AUTHORIZATION']
      unless access_token.nil?
        decrypted_access_token = Base64.strict_decode64(access_token)
        @api_key = ApiKey.find_by(access_token: decrypted_access_token, active: true)
        @player = @api_key.try(:player)
      end
    rescue ActiveRecord::StatementInvalid
    end

    if !@player && (params[:controller] != 'api/v1/sessions' && params[:action] != 'destroy')
      raise ApiErrors::AuthTokenNotFoundError
    end
  end
end