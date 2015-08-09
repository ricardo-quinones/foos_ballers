class Api::V1::PlayersController < Api::V1::BaseController
  before_filter :get_player, only: [:show, :first_unfinished_match]

  def index
    render json: { players: Player.game_stats }, status: :ok
  end

  def create
    player = Player.new(player_params)
    player.save!
    session[:current_user_id] = player.id
    render json: { auth_token: player.first_active_encrypted_access_token, player: player.stats.as_json }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { developer_error: e.message, messages: player.errors.full_messages }, status: :bad_request
  end

  def show
    render json: { player: @player.stats.as_json }, status: :ok
  end

  def first_unfinished_match
    render :first_unfinished_match, formats: [:json], handlers: [:jbuilder], status: :ok
  end

  # Proc to be called by autocomplete api call to allow for better filtering of
  # the results
  def self.player_autocomplete_where_option
    lambda do |params|
      return unless params[:ids_not_in].is_a?(Array)
      ActiveRecord::Base.send(:sanitize_sql,["players.id NOT IN (?)", params[:ids_not_in]], '')
    end
  end

  autocomplete :player, :name, where: player_autocomplete_where_option

  private

  def player_params
    params.require(:player).permit(:name, :email, :password, :password_confirmation)
  end
end