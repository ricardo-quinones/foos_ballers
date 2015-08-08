angular.module('controllers.update_match_score', [])

.controller 'UpdateMatchScoreController', ['$scope', '$timeout', 'Match', 'Session', 'Players',
  ($scope, $timeout, Match, Session, Players) ->
    $scope.$on 'setCurrentMatch', (e, currentMatch) ->
      $scope.currentMatch = currentMatch

    $scope.matchParticipantTitle = (team) ->
      _.map(team.players, (player) -> player.name).join('/')

    $scope.postScore = ->
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

]