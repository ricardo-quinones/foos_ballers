json.auth_token @player.generate_new_api_key!.encrypted_access_token
json.player @player.stats.as_json
json.partial! 'api/v1/matches/unfinished_match', match: @player.get_first_unfinished_match
