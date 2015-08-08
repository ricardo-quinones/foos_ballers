angular.module('services.matches', [])

.service 'Match', ['$http', 'BASE_URL',
  ($http, BASE_URL) ->
    @pendingMatches = []

    @create = (matchParams) ->
      $http.post("#{BASE_URL}/matches", { match: matchParams })
      .success (data, success, headers, config) =>
        @pendingMatches.push(data.match)

    @update = (id, updateParams) ->
      $http.put("#{BASE_URL}/matches/#{id}", { match: updateParams })
      .success (data, success, headers, config) =>
        @pendingMatches = _.without(@pendingMatches, id)

    return @
]
