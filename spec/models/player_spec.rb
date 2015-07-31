require 'spec_helper'

describe Player do
  let(:player_1) { Player.create(name: 'Baller Bank') }
  let(:player_2) { Player.create(name: 'Mean Greene') }
  let(:player_3) { Player.create(name: 'Managed by Q') }
  let(:player_4) { Player.create(name: 'Rusty Raymond') }

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
