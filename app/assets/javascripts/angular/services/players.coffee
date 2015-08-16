angular.module('services.players', [])

.service 'Players', ['$http', 'BASE_URL',
  ($http, BASE_URL) ->
    @all = []

    class Player
      constructor: (player) ->
        @name              = player.name
        @games             = player.games
        @rating            = -> player.rating
        @goals_scored      = -> player.goals_scored
        @goals_allowed     = -> player.goals_allowed
        @games_won         = -> player.games_won

      total_games: ->
        @games

      losses: ->
        @games - @games_won()

      winning_percentage: ->
        return 0 unless @games
        parseInt(@games_won() / @games * 100)

      winning_percentage_formatter: ->
        "#{@winning_percentage()}%"

      goal_differential: ->
        @goals_scored() - @goals_allowed()

      avg_goal_differential: ->
        total_games = @total_games()
        return 0 unless total_games
        @goal_differential() / total_games

      avg_goal_differential_formatter: ->
        avg = Math.round(@avg_goal_differential() * 10) / 10
        "#{avg}/match"

    @fetch = ->
      $http.get("#{BASE_URL}/players")
      .success (data, status, headers, config) =>
        @all = _.map data.players, (player) -> new Player(player)

    @autocomplete = (query, idsNotIn) ->
      getParams = {
        method: 'GET',
        url:    "#{BASE_URL}/players/autocomplete_player_name",
        params: { term: query }
      }

      if idsNotIn && idsNotIn.length
        getParams.params["ids_not_in[]"] = idsNotIn

      $http(getParams)

    @create = (playerParams) ->
      $http.post("#{BASE_URL}/players", { player: playerParams })
      .success (data, status, headers, config) =>
        @all.push(new Player(data.player))

    @first_unfinished_match = (id) ->
      $http.get("#{BASE_URL}/players/#{id}/first_unfinished_match")

    return @
]
