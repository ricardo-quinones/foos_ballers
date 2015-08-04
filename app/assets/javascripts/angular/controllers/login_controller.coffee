angular.module('controllers.login', [])

.controller 'LoginController', ['$scope', 'Session',
  ($scope, Session) ->
    $scope.login = ->
      Session.login($scope.email, $scope.password)
      .then (response) ->
        $scope.password     = null
        $scope.email        = null
        Session.currentUser = response.data.player
        $scope.$emit('closePanel', 'login')
      .catch (errorMessages) ->
        $scope.$emit('displayError', errorMessages[0])
]
