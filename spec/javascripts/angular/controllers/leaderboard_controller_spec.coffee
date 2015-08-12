document.write('<script type="text/javascript" src="//code.angularjs.org/1.4.2/angular-mocks.js"><\/script>')

describe "LeaderboardController", ->
  beforeEach ->
    module('foosBallers')

    inject ($rootScope, $controller, $httpBackend, Players, BASE_URL) ->
      @Players = Players
      @httpBackend = $httpBackend
      @scope = $rootScope.$new()

      @controller = $controller(
        'LeaderboardController',
        { $scope: @scope, Players: Players }
      )

      @scope.displayedStat = 'games_won'

      response = {
        players: [
          {id: 1,  name: 'Baller Bank',   games: 3, games_won: 2},
          {id: 2,  name: 'Mean Greene',   games: 2, games_won: 3},
          {id: 3,  name: 'Rusty Raymond', games: 1, games_won: 1},
          {id: 4,  name: 'Managed by Q',  games: 1, games_won: 3}
        ]
      }

      @httpBackend.when('GET', "#{BASE_URL}/players").respond(response, {})

  describe '#rank', ->
    it "finds the correct rank for the players", ->
      @httpBackend.flush()

      ballerBank   = @scope.players()[0]
      meanGreene   = @scope.players()[1]
      rustyRaymond = @scope.players()[2]
      mQ           = @scope.players()[3]

      expect(@scope.rank(mQ))          .toEqual(1)
      expect(@scope.rank(meanGreene))  .toEqual(1)
      expect(@scope.rank(ballerBank))  .toEqual(3)
      expect(@scope.rank(rustyRaymond)).toEqual(4)


