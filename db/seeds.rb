# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


player_1 = Player.create(name: 'Baller Bank')
player_2 = Player.create(name: 'Mean Greene')
player_3 = Player.create(name: 'Managed by Q')
player_4 = Player.create(name: 'Rusty Raymond')
team_1   = Team.create(player_1: player_1, player_2: player_2)
team_2   = Team.create(player_1: player_3, player_2: player_4)
Match.create(team_1: team_1, team_2: team_2, winner: team_1)