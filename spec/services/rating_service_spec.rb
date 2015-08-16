require 'spec_helper'

describe RatingService do
  let(:match)              { create(:match) }
  let(:match_participants) { match.match_participants }
  let(:winner_id)          { match_participants[0].id }
  let(:results) do
    {
      match_participants_attributes: [
        { id: match.match_participants[0].id, goals: 10 }, # winner
        { id: match.match_participants[1].id, goals: 8 }
      ]
    }
  end

  describe ".normalize_results" do
    let(:normalized_results) { described_class.send(:normalize_results, match_participants, winner_id, results) }

    context 'checking the quantity of keys' do
      subject { normalized_results }
      its('keys.count') { is_expected.to eq(2) }
    end

    context 'default mean and deviation values for the winner' do
      subject { normalized_results.keys.first }
      its(:count) { is_expected.to eq(2) }
      its('first.mean')      { is_expected.to eq(25) }
      its('first.deviation') { is_expected.to eq(25 / 3.0) }
      specify { expect(normalized_results[subject]).to eq(2) }
    end

    context 'default mean and deviation values for the loser' do
      subject { normalized_results.keys.last }
      its(:count) { is_expected.to eq(2) }
      its('first.mean')      { is_expected.to eq(25) }
      its('first.deviation') { is_expected.to eq(25 / 3.0) }
      specify { expect(normalized_results[subject]).to eq(-2) }
    end
  end

  describe ".goal_differential" do
    subject { described_class.send(:goal_differential, results) }
    it { is_expected.to eq(2) }
  end

  describe ".update_ratings" do
    0.upto(3) do |i|
      it "creates new ratings for each player" do
        expect {
          described_class.update_ratings(match, winner_id, results)
        }.to change { match.players[i].ratings.count }.from(0).to(1)
      end
    end

    context 'checking a random winner and loser' do
      before { described_class.update_ratings(match, winner_id, results) }

      context 'a winning player' do
        subject { match.match_participants.where(id: winner_id).first.players.sample }
        its('current_rating.trueskill_mean')      { is_expected.to be > RatingService::DEFAULT_MEAN }
        its('current_rating.trueskill_deviation') { is_expected.to be < RatingService::DEFAULT_DEVIATION }
      end

      context 'a losing player' do
        subject { match.match_participants.where.not(id: winner_id).first.players.sample }
        its('current_rating.trueskill_mean')      { is_expected.to be < RatingService::DEFAULT_MEAN }
        its('current_rating.trueskill_deviation') { is_expected.to be < RatingService::DEFAULT_DEVIATION }
      end
    end

  end
end
