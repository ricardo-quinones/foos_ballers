angular.module('controllers.add_match', [])

.controller 'AddMatchController', ['$scope', 'Match', 'Players',
  ($scope, Match, Players) ->
    $scope.addMatch = ->
      Match.create(addMatchData())
      .then (response) ->
        $scope.team_1 = []
        $scope.team_2 = []
        $scope.$emit('closePanel', 'addMatch')
      .catch (errorMessages) ->
        $scope.$emit('displayError', errorMessages[0])

    $scope.loadTags = (query) ->
      Players.autocomplete(query, idsNotIn())

    # Private functions

    addMatchData = ->
      {
        team_1: _.map($scope.team_1, (p) -> p.id),
        team_2: _.map($scope.team_2, (p) -> p.id)
      }

    teams = ->
      ($scope.team_1 || []).concat($scope.team_2 || [])

    idsNotIn = ->
      _.map teams(), (player) -> player.id
]
