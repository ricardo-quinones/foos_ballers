angular.module('controllers.leaderboard', [])

.controller 'LeaderboardController', ['$scope', 'Players',
  ($scope, Players) ->
    Players.fetch()

    $scope.displayedStat = 'rating'

    STAT_TITLE_MAPPING = {
      'games_won':          'Games won',
      'winning_percentage': 'Winning percentage'
      'total_games':        'Total games',
      'losses':             'Losses',
      'rating':             'Rating',
      'goals_scored':       'Goals Scored',
      'goals_allowed':      'Goals Allowed',
      'goal_differential':  'Goal Differential'
    }

    $scope.possibleStats = ->
      _.keys(STAT_TITLE_MAPPING)

    $scope.statLabel = (stat) ->
      STAT_TITLE_MAPPING[stat]

    $scope.changeDisplayedStat = (stat) ->
      $scope.displayedStat    = stat
      $scope.showStatDropdown = false

    $scope.players = ->
      Players.all

    $scope.currentStatDisplay = (player) ->
      if player["#{$scope.displayedStat}_formatter"]
        player["#{$scope.displayedStat}_formatter"]()
      else
        $scope.currentStat(player)

    $scope.currentStat = (player) ->
      player[$scope.displayedStat]()

    $scope.currentStatHeaderTitle = ->
      STAT_TITLE_MAPPING[$scope.displayedStat]

    $scope.rankingArray = ->
      _.sortBy(_.map($scope.players(), (p) -> $scope.currentStat(p)), (el) -> -el)

    $scope.rank = (player) ->
      _.indexOf($scope.rankingArray(), $scope.currentStat(player)) + 1
]
