angular.module('foosBallers', [
  'ngCookies',
  'ngTagsInput',
  'constants',
  'general_directives',
  'services',
  'controllers'
])

.config ['$httpProvider', 'tagsInputConfigProvider', ($httpProvider, tagsInputConfigProvider) ->
  tagsInputConfigProvider.setTextAutosizeThreshold(90)
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

.factory 'interceptHandler', ['$q',
  ($q) ->
    {
      responseError: (response) ->
        if response.status && response.status >= 300
          $q.reject(response)
        else
          response
    }
]