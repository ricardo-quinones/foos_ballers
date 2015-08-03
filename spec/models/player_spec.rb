require 'spec_helper'

describe Player do
  let(:player_1) { create(:player, :baller_bank) }
  let(:player_2) { create(:player, :mean_greene) }
  let(:player_3) { create(:player, :rusty_raymond) }
  let(:player_4) { create(:player) }

  let(:team_1) { Team.create(player_1: player_1, player_2: player_2) }
  let(:team_2) { Team.create(player_1: player_3, player_2: player_4) }

  let!(:match)  { Match.create(team_1: team_1, team_2: team_2, winner: team_1) }

  context 'the match' do
    subject { match }
    its(:winner) { is_expected.to eq(team_1) }
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
