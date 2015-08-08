if match
  json.match do |json|
    json.id match.id
    json.match_participants_attributes match.match_participants, :id, :goals
    json.teams do |json|
      json.array! match.teams do |team|
        json.players team.players, :name
      end
    end
  end
else
  json.match nil
end
