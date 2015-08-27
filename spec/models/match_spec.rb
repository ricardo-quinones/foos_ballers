require 'spec_helper'

describe Match do
  describe "#reset!" do
    let!(:match) { create(:match) }
    let(:actual_winner) { match.match_participants[0] }
    let(:actual_loser)  { match.match_participants[1] }
    let(:update_params) do
      {
        match_participants_attributes: [
          { id: match.match_participants[0].id, goals: 8 }, # The actual winner
          { id: match.match_participants[1].id, goals: 10 }
        ]
      }
    end

    before { match.post_score!(update_params) }

    it "resets the bad match" do
      expect { match.reset! }.to change { match.winner }.from(actual_loser).to(nil)
    end

    it "changes the current status of each player" do
      match.players.each do |p|
        expect(p.current_rating).to_not be_nil
      end

      match.reset!

      match.players.each do |p|
        expect(p.current_rating).to be_nil
      end
    end

    it "destroys the incorrectly created statuses of the players" do
      expect {
        match.reset!
      }.to change { Rating.count }.from(4).to(0)
    end
  end
end
