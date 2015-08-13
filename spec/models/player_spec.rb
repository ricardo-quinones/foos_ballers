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


    def update_hash(match, team_1_goals = 10, team_2_goals = 8)
      {
        match_participants_attributes: [
          { id: match.match_participants[0].id, goals: team_1_goals },
          { id: match.match_participants[1].id, goals: team_2_goals }
        ]
      }
    end

    # Winners = player_1 & player_2
    # Losers  = player_3 & player_4
    before { match.post_score!(update_hash(match)) }

    describe ".game_stats" do
      let(:game_stats_array) { described_class.game_stats.as_json }

      context 'the games stats array' do
        subject { game_stats_array }

        it { is_expected.to be_a(Array) }
        its(:length) { is_expected.to eq(4) }
      end

      context 'the first player on team 1' do
        subject { game_stats_array.find { |a| a['id'] == player_1.id } }
        it { is_expected.to have_key('id') }
        it { is_expected.to have_key('name') }

        its(['games_won'])     { is_expected.to eq(1) }
        its(['games'])         { is_expected.to eq(1) }
        its(['goals_scored'])  { is_expected.to eq(10) }
        its(['goals_allowed']) { is_expected.to eq(8) }
      end

      context 'with another game' do
        before do
          new_match = Match.create(teams: [team_1, team_2])
          # Winners = player_3 & player_4
          # Losers  = player_1 & player_2
          new_match.post_score!(update_hash(new_match, 3, 10))
        end

        context 'the first player from the first team' do
          subject { game_stats_array.find { |a| a['id'] == player_1.id } }
          its(['games_won'])     { is_expected.to eq(1) }
          its(['games'])         { is_expected.to eq(2) }
          its(['goals_scored'])  { is_expected.to eq(13) }
          its(['goals_allowed']) { is_expected.to eq(18) }
        end

        context 'the last player from the second team' do
          subject { game_stats_array.find { |a| a['id'] == player_4.id } }
          its(['games_won'])     { is_expected.to eq(1) }
          its(['games'])         { is_expected.to eq(2) }
          its(['goals_scored'])  { is_expected.to eq(18) }
          its(['goals_allowed']) { is_expected.to eq(13) }
        end

        context 'with a different combination of teams to' do
          before do
            new_team_1 = Team.create(players: [player_1, player_4])
            new_team_2 = Team.create(players: [player_2, player_3])
            new_match  = Match.create(teams: [new_team_1, new_team_2])
            # Winners = player_2 & player_3
            # Losers  = player_1 & player_4
            new_match.post_score!(update_hash(new_match, 7, 10))
          end

          context 'the stats of player 1' do
            subject { game_stats_array.find { |a| a['id'] == player_1.id } }
            its(['games_won'])     { is_expected.to eq(1) }
            its(['games'])         { is_expected.to eq(3) }
            its(['goals_scored'])  { is_expected.to eq(20) }
            its(['goals_allowed']) { is_expected.to eq(28) }
          end

          context 'the stats of player 2' do
            subject { game_stats_array.find { |a| a['id'] == player_2.id } }
            its(['games_won'])     { is_expected.to eq(2) }
            its(['games'])         { is_expected.to eq(3) }
            its(['goals_scored'])  { is_expected.to eq(23) }
            its(['goals_allowed']) { is_expected.to eq(25) }
          end

          context 'the stats of player 3' do
            subject { game_stats_array.find { |a| a['id'] == player_3.id } }
            its(['games_won'])     { is_expected.to eq(2) }
            its(['games'])         { is_expected.to eq(3) }
            its(['goals_scored'])  { is_expected.to eq(28) }
            its(['goals_allowed']) { is_expected.to eq(20) }
          end

          context 'the stats of player 4' do
            subject { game_stats_array.find { |a| a['id'] == player_4.id } }
            its(['games_won'])     { is_expected.to eq(1) }
            its(['games'])         { is_expected.to eq(3) }
            its(['goals_scored'])  { is_expected.to eq(25) }
            its(['goals_allowed']) { is_expected.to eq(23) }
          end
        end
      end
    end

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

  describe "#generate_new_api_key!" do
    subject { create(:player) }
    its(:api_keys)                     { is_expected.not_to be_empty }
    its('api_keys.first.access_token') { is_expected.to be_a(String) }
  end
end
