angular.module('controllers.main', [])

.controller 'MainAppController', ['$scope', 'Session', 'Players',
  ($scope, Session, Players) ->
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

    $scope.$on 'signedIn', ->
      $('.add-match').removeClass('no-pulse')

    $scope.$on 'updateCurrentMatch', (e, currentMatch) ->
      $scope.$broadcast('setCurrentMatch', currentMatch)
      $scope.$emit('openPanel', 'updateScore')

    $scope.$on 'updateLogin', ->
      Session.logout()
      $scope.$emit('openPanel', 'login')
      $scope.$emit('displayError', 'Oops! Looks like you need to login again.')

    $scope.currentUser = ->
      Session.currentUser

    $scope.loggedIn = ->
      Session.currentUser?

    $scope.init = (user) ->
      if user
        Session.currentUser = user
        $scope.$emit('signedIn')
        Players.first_unfinished_match(Session.currentUser.id)
        .then (response) ->
          if response.data.match
            $scope.$emit('updateCurrentMatch', response.data.match)
]