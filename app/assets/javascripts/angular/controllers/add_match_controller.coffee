angular.module('controllers.add_match', [])

.controller 'AddMatchController', ['$scope', 'Match', 'Players',
  ($scope, Match, Players) ->
    $scope.addMatch = ->
      Match.create($scope.addMatchData)
      .then (response) ->
        $scope.addMatchData = {}
        $scope.$emit('closePanel', 'addMatch')
      .catch (response) ->
        $scope.$emit('displayError', response.data.messages[0])

    idsNotIn = ->
      ids = []
      angular.forEach $scope.addMatchData, (team, key) ->
        angular.forEach team, (player) ->
          ids.push(player.player_id)
      ids

    $scope.loadTags = (query) ->
      Players.autocomplete(query, idsNotIn())
]