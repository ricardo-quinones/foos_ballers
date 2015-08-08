json.auth_token @player.encrypted_auth_token
json.player @player.stats.as_json
json.partial! 'api/v1/matches/unfinished_match', match: @player.get_first_unfinished_match
