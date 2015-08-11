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

        context 'the body of the response' do
          before  { post :create, match: match_params }
          subject { JSON.parse(response.body).with_indifferent_access }
          it { is_expected.to have_key(:match) }
          its([:match]) { is_expected.to have_key(:match_participants_attributes) }
          its([:match]) { is_expected.to have_key(:teams) }

          let(:match) { subject[:match] }

          let(:match_participants_attributes) { match[:match_participants_attributes] }
          specify { expect(match_participants_attributes.length).to eq(2) }
          specify { expect(match_participants_attributes.first).to have_key(:id) }
          specify { expect(match_participants_attributes.first).to have_key(:goals) }

          let(:teams) { match[:teams] }
          specify { expect(teams.length).to eq(2) }
          specify { expect(teams.first).to have_key(:players) }

          let(:team_players) { teams.first[:players] }
          specify { expect(team_players.length).to eq(2) }
          specify { expect(team_players.first).to have_key(:name) }
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

    context 'as an authorized player' do
      let(:api_key) { match.players.first.api_keys.first }

      before do
        request.headers['HTTP_AUTHORIZATION'] = api_key.encrypted_access_token
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
        }.to change { loser.reload.goals }.from(0).to(8)
      end
    end
  end
end
