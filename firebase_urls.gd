extends Node

const HOST_URL = "https://godot-multiplayer-firebase-default-rtdb.europe-west1.firebasedatabase.app"
 
func get_player_url(player_id) -> String:
	return HOST_URL + ("/players/%s.json" % player_id)

func get_players_url() -> String:
	return HOST_URL + "/players.json"
