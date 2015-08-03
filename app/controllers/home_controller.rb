class HomeController < ApplicationController
  def leaderboard
    @current_user = Player.find(session[:current_user_id]) if session[:current_user_id]
  end
end