class Api::V1::MatchesController < Api::V1::BaseController
  def create
    team_1 = Team.find_team(team_1_params)
    team_2 = Team.find_team(team_2_params)

    team_1 ||= Team.create!(players: Player.where(id: team_1_params))
    team_2 ||= Team.create!(players: Player.where(id: team_2_params))

    @match  = Match.create!(teams: [team_1, team_2])
    # render json: { match: { id: @match.id } }, status: :created
    render :create, formats: [:json], handlers: [:jbuilder], status: :created
  end

  def update
    match = Match.find(params[:id])
    match.post_score!(post_score_params)
    head :accepted
  end

  private

  def team_1_params
    params.require(:match).require(:team_1)
  end

  def team_2_params
    params.require(:match).require(:team_2)
  end

  def post_score_params
    params.require(:match).permit(match_participants_attributes: [:id, :goals])
  end
end
