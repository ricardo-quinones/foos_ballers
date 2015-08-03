angular.module('controllers.leaderboard', [])

.controller 'LeaderboardController', ['$scope', 'Players',
  ($scope, Players) ->
    Players.fetch()

    $scope.displayedStat = 'games_won'

    STAT_TITLE_MAPPING = {
      'games_won': 'Games won',
      'winning_percentage': 'Winning percentage'
    }

    $scope.players = ->
      Players.all

    $scope.currentStat = (player) ->
      player[$scope.displayedStat]()

    $scope.currentStatHeaderTitle = ->
      STAT_TITLE_MAPPING[$scope.displayedStat]

    $scope.rankingArray = ->
      _.sortBy(_.uniq(_.map $scope.players(), (p) -> $scope.currentStat(p)), (el) -> -el)

    $scope.rank = (player) ->
      _.indexOf($scope.rankingArray(), $scope.currentStat(player)) + 1
]