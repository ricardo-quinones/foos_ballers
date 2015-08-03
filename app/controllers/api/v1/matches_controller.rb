class Api::V1::MatchesController < Api::V1::BaseController
  def create
    team_1 = Team.where(team_1_params).first_or_create
    team_2 = Team.where(team_2_params).first_or_create
    Match.create!(team_1: team_1, team_2: team_2)
    head :created
  end

  private

  def team_1_params
    params
      .require(:match)
      .permit(team_1: [:player_1_id, :player_2_id])
      .require(:team_1)
  end

  def team_2_params
    params
      .require(:match)
      .permit(team_2: [:player_1_id, :player_2_id])
      .require(:team_2)
  end
end