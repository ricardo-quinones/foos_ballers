class Api::V1::PlayersController < ApplicationController
  def index
    render json: { players: Player.game_stats }, status: :ok
  end
end