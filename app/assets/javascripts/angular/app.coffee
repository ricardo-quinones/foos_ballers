angular.module('foosBallers', [
  'templates',
  'ngCookies',
  'ngTagsInput',
  'constants',
  'general_directives',
  'services',
  'controllers'
])

.config ['$httpProvider', 'tagsInputConfigProvider', ($httpProvider, tagsInputConfigProvider) ->
  tagsInputConfigProvider.setTextAutosizeThreshold(400)
  ct = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = ct
  $httpProvider.defaults.headers.post["Content-Type"]   = 'application/json'
  $httpProvider.defaults.headers.put["Content-Type"]    = 'application/json'
  $httpProvider.interceptors.push('interceptHandler')
]

.run ['$http', '$cookies', 'CKID', 'Session', ($http, $cookies, CKID, Session) ->
  at = $cookies.get(CKID)
  if at
    $http.defaults.headers.common.Authorization = at
]

.factory 'interceptHandler', ['$q', 'DEFAULT_ERROR_MESSAGE',
  ($q, DEFAULT_ERROR_MESSAGE) ->
    errorMessages = (response) ->
      if _.isArray(response.data.messages)
        response.data.messages
      else
        [DEFAULT_ERROR_MESSAGE]

    {
      responseError: (response) ->
        if response.status && response.status >= 300
          $q.reject(errorMessages(response))
        else
          response
    }
]
