angular.module('controllers.update_match_score', [])

.controller 'UpdateMatchScoreController', ['$scope', 'Match',
  ($scope, Match) ->
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
]