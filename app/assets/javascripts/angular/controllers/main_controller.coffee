angular.module('controllers.main', [])

.controller 'MainAppController', ['$scope', 'Session',
  ($scope, Session) ->
    $scope.openPanel = {}

    # Event listeners
    $scope.$on 'openNav', ->
      $scope.navOpen = true

    $scope.$on 'closeNav', ->
      $scope.navOpen = false

    $scope.$on 'openPanel', (e, panelType) ->
      $scope.navOpen = false

      _.each $scope.openPanel, (v, panel) ->
        $scope.openPanel[panel] = false if panel != panelType

      $scope.openPanel[panelType] = true

    $scope.$on 'closePanel', (e, panelType) ->
      $scope.openPanel[panelType] = false

    $scope.$on 'updateCurrentMatch', (e, currentMatch) ->
      $scope.$broadcast('setCurrentMatch', currentMatch)
      $scope.$emit('openPanel', 'updateScore')

    $scope.currentUser = ->
      Session.currentUser

    $scope.loggedIn = ->
      Session.currentUser?

    $scope.init = (user) ->
      Session.currentUser = user if user
]