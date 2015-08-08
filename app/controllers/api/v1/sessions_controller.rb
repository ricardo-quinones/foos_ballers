class Api::V1::SessionsController < Api::V1::BaseController
  before_filter :get_player, only: [:destroy]

  def create
    @player = Player.find_by(email: params[:email])

    raise ApiErrors::EmailNotFoundError unless @player
    raise ApiErrors::AuthenticationError unless @player.authenticate(params[:password])

    session[:current_user_id] = @player.id
    render :create, formats: [:json], handlers: [:jbuilder], status: :created
  end

  def destroy
    @player.reset_authentication_token!
    session.delete(:current_user_id)
    head :accepted
  end
end