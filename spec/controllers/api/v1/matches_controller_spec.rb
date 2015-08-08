require 'spec_helper'

describe Api::V1::MatchesController, type: :controller do
  describe "POST create" do
    let(:player_1) { create(:player, :baller_bank) }
    let(:player_2) { create(:player, :mean_greene) }
    let(:player_3) { create(:player, :rusty_raymond) }
    let(:player_4) { create(:player) }

    let(:match_params) do
      {
        team_1: [player_1.id, player_2.id],
        team_2: [player_3.id, player_4.id]
      }
    end

    context 'successfully creating a match' do
      context 'with non-existing teams' do
        context 'the response' do
          before  { post :create, match: match_params }
          subject { response }
          its(:status) { is_expected.to eq(201) }
        end

        context 'the body of the response' do
          before  { post :create, match: match_params }
          subject { JSON.parse(response.body).with_indifferent_access }
          it { is_expected.to have_key(:match) }
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

  describe "PUT update" do
    let!(:match) { create(:match) }
    let(:winner) { match.match_participants[0] }
    let(:loser)  { match.match_participants[1] }
    let(:update_params) do
      {
        match_participants_attributes: [
          { id: match.match_participants[0].id, goals: 10 }, # The winner
          { id: match.match_participants[1].id, goals: 8 }
        ]
      }
    end

    context 'the response' do
      before { put :update, { match: update_params }.merge(id: match.id) }
      subject      { response }
      its(:status) { is_expected.to eq(202) }
    end

    it "correctly updates the winner of the match" do
      expect {
        put :update, { match: update_params }.merge(id: match.id)
      }.to change { match.reload.winner }.from(nil).to(winner.reload)
    end

    it "correctly updates the goals of the winner" do
      expect {
        put :update, { match: update_params }.merge(id: match.id)
      }.to change { loser.reload.goals }.from(nil).to(8)
    end
  end
end
