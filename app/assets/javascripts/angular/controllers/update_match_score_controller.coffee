angular.module('controllers.update_match_score', [])

.controller 'UpdateMatchScoreController', ['$scope', '$timeout', '$q', 'Match', 'Session', 'Players',
  ($scope, $timeout, $q, Match, Session, Players) ->
    $scope.$on 'setCurrentMatch', (e, currentMatch) ->
      $scope.currentMatch = currentMatch

    $scope.matchParticipantTitle = (team) ->
      _.map(team.players, (player) -> player.name).join('/')

    $scope.postScore = ->
      if window.confirm(confirmationMessage())
        updateParams = _.omit($scope.currentMatch, 'id')
        Match.update($scope.currentMatch.id, updateParams)
        .then (response) ->
          $scope.currentMatch = null
          $scope.$emit('closePanel', 'updateScore')
          Players.first_unfinished_match(Session.currentUser.id)
        .then (response) ->
          if response.data.match
            $timeout ->
              $scope.$emit('updateCurrentMatch', response.data.match)
            , 500
      else
        deferred = $q.defer()
        deferred.resolve()
        deferred.promise

    winningIndex = ->
      mpa = $scope.currentMatch.match_participants_attributes
      if mpa[0].goals > mpa[1].goals then 0 else 1

    winningTeam = ->
      $scope.currentMatch.teams[winningIndex()]

    didBucklesWin = ->
      wt = winningTeam()
      _.some wt.players, (player) ->
        /buckley/i.test(player.name)

    confirmationMessage = ->
      if didBucklesWin()
        "Wait...really? Buckley won? You sure that's not a mistake?"
      else
        "Are you sure? Umang doesn't like mistakes."

]