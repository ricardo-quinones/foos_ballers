angular.module('services.players', [])

.service 'Players', ['$http', 'BASE_URL',
  ($http, BASE_URL) ->
    @all = []

    class Player
      constructor: (player) ->
        @name      = player.name
        @games     = player.games
        @games_won = -> player.games_won

      winning_percentage: ->
        parseInt(@games_won() / @games * 100)

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

    return @
]
