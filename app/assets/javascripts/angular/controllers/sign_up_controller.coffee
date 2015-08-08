angular.module('controllers.sign_up', [])

.controller 'SignUpController', ['$scope', 'Players', 'Session',
  ($scope, Players, Session) ->
    $scope.signUp = ->
      Players.create($scope.signUpFormData)
      .then (response) ->
        Session.loginUserWithCredentials(response.data.auth_token, response.data.player)
        $scope.signUpFormData = {}
        $scope.$emit('signedIn')
        $scope.$emit('closePanel', 'signUp')
      .catch (errorMessages) ->
        $scope.$emit('displayError', errorMessages[0])
]
