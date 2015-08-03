angular.module('controllers.navigation', [])

.controller 'NavigationController', ['$scope', 'Session',
  ($scope, Session) ->
    $scope.logout = ->
      Session.logout()
      .then (response) ->
        $scope.$emit('closeNav')
]