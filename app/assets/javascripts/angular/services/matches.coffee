angular.module('services.matches', [])

.service 'Match', ['$http', 'BASE_URL',
  ($http, BASE_URL) ->
    @create = (matchParams) ->
      $http.post("#{BASE_URL}/matches", { match: matchParams })
      .success (data, success, headers, config) =>
        console.log('success')

    return @
]