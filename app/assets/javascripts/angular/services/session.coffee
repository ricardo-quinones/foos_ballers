angular.module('services.session', [])

.service 'Session', ['$http', '$cookies', 'BASE_URL', 'CKID',
  ($http, $cookies, BASE_URL, CKID) ->
    @loginUserWithCredentials = (token, player) =>
      $http.defaults.headers.common.Authorization = token
      $cookies.put(CKID, token)
      @currentUser = player

    @login = (email, password) =>
      loginParams  = { email: email, password: password }
      $http.post("#{BASE_URL}/sessions", loginParams)
      .success (data, status, headers, config) =>
        @loginUserWithCredentials(data.auth_token, data.player)

    @logout = =>
      $http.delete("#{BASE_URL}/sessions")
      .success (data, status, headers, config) =>
        delete $http.defaults.headers.common.Authorization
        $cookies.remove(CKID)
        @currentUser = null

    return @
]
