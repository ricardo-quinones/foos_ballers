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
      formData = { team_1: {}, team_2: {} }
      angular.forEach $scope.team_1, (player, index) ->
        formData.team_1["player_#{index + 1}_id"] = player.id

      angular.forEach $scope.team_2, (player, index) ->
        formData.team_2["player_#{index + 1}_id"] = player.id

      formData

    teams = ->
      ($scope.team_1 || []).concat($scope.team_2 || [])

    idsNotIn = ->
      _.map teams(), (player) -> player.id
]
