require 'saulabs/trueskill'

class RatingService
  DEFAULT_MEAN      = 25
  DEFAULT_DEVIATION = 25.0 / 3.0

  class << self
    def update_ratings(match, winner_id, results)
      match_participants = match.match_participants.includes(players: [:current_rating]).to_a
      normalized_results = normalize_results(match_participants, winner_id, results)
      graph = Saulabs::TrueSkill::ScoreBasedBayesianRating.new(normalized_results)
      graph.update_skills

      match_participants.each_with_index do |mp, mp_index|
        mp_updated_skills = normalized_results.keys[mp_index]

        mp.players.each_with_index do |player, p_index|
          new_rating = mp_updated_skills[p_index]
          player.set_current_rating!(new_rating.mean, new_rating.deviation, match)
        end
      end
    end

    def rating(mean, deviation)
      (mean - (3 * deviation)) * 100
    end

    private

    def normalize_results(match_participants, winner_id, results)
      goal_differential = goal_differential(results)

      match_participants.each_with_object({}) do |match_participant, hash|
        updated_participant = results[:match_participants_attributes].find do |mp|
          mp[:id].to_i == match_participant.id
        end

        key = match_participant.players.map do |player|
          current_rating = player.current_rating
          mean      = current_rating.try(:trueskill_mean)      || DEFAULT_MEAN
          deviation = current_rating.try(:trueskill_deviation) || DEFAULT_DEVIATION
          Saulabs::TrueSkill::Rating.new(mean, deviation)
        end

        hash[key] = (updated_participant[:id] == winner_id ? goal_differential : -goal_differential)
      end
    end

    def goal_differential(results)
      results[:match_participants_attributes]
        .map { |mp| mp[:goals].to_i }
        .inject(:-)
        .abs
    end
  end
end
