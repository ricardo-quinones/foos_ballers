require 'spec_helper'

describe Api::V1::MatchesController, type: :controller do
  describe "POST create" do
    let(:player_1) { create(:player, :baller_bank) }
    let(:player_2) { create(:player, :mean_greene) }
    let(:player_3) { create(:player, :rusty_raymond) }
    let(:player_4) { create(:player) }

    let(:match_params) do
      {
        team_1: {
          player_1_id: player_1.id,
          player_2_id: player_2.id
        },
        team_2: {
          player_1_id: player_3.id,
          player_2_id: player_4.id
        }
      }
    end

    context 'successfully creating a match' do
      context 'with non-existing teams' do
        context 'the response' do
          before  { post :create, match: match_params }
          subject { response }
          its(:status) { is_expected.to eq(201) }
        end

        it 'creates 2 new teams' do
          expect {
            post :create, match: match_params
          }.to change { Team.count }.from(0).to(2)
        end

        it "creates a match" do
          expect {
            post :create, match: match_params
          }.to change { Match.count }.from(0).to(1)
        end
      end

      context 'with existing teams' do
        let(:team_1) { Team.create(player_1: player_1, player_2: player_2) }
        let(:team_2) { Team.create(player_1: player_3, player_2: player_4) }

        context 'the response' do
          before  { post :create, match: match_params }
          subject { response }
          its(:status) { is_expected.to eq(201) }
        end

        it "does not create new teams" do
          expect {
            post :create, match: match_params
          }.to change { Team.count }
        end

        it "creates a match" do
          expect {
            post :create, match: match_params
          }.to change { Match.count }.from(0).to(1)
        end
      end
    end
  end
end
