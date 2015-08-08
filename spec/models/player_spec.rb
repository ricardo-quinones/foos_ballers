require 'spec_helper'

describe Player do
  context 'saving players, teams, and matches' do
    let(:player_1) { create(:player, :baller_bank) }
    let(:player_2) { create(:player, :mean_greene) }
    let(:player_3) { create(:player, :rusty_raymond) }
    let(:player_4) { create(:player) }
    let(:team_1)   { Team.create(players: [player_1, player_2]) }
    let(:team_2)   { Team.create(players: [player_3, player_4]) }
    let!(:match)   { Match.create(teams: [team_1, team_2]) }
    let(:winning_participant) { match.match_participants.first }

    let(:update_hash) do
      {
        match_participants_attributes: [
          { id: match.match_participants[0].id, goals: 10 }, # The winner
          { id: match.match_participants[1].id, goals: 8 }
        ]
      }
    end

    before { match.post_score!(update_hash) }

    context 'the match' do
      subject { match }
      its(:winner) { is_expected.to eq(winning_participant) }
    end

    context 'a winning team' do
      subject { team_1 }
      its('matches.count') { is_expected.to eq(1) }
      its('wins.count')    { is_expected.to eq(1) }
      its('losses.count')  { is_expected.to eq(0) }
    end

    context 'a losing team' do
      subject { team_2 }
      its('matches.count') { is_expected.to eq(1) }
      its('wins.count')    { is_expected.to eq(0) }
      its('losses.count')  { is_expected.to eq(1) }
    end

    context 'a winning player' do
      subject { player_1 }
      its('matches.count') { is_expected.to eq(1) }
      its('wins.count')    { is_expected.to eq(1) }
      its('losses.count')  { is_expected.to eq(0) }
    end

    context 'a losing player' do
      subject { player_3 }
      its('matches.count') { is_expected.to eq(1) }
      its('wins.count')    { is_expected.to eq(0) }
      its('losses.count')  { is_expected.to eq(1) }
    end
  end

  describe "#bankify_name" do
    subject { create(:player, name: 'Mayank') }
    its(:name) { is_expected.to eq('Mayank Bank') }
  end
end
