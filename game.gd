extends Node

@export var local_player: PlayerControllerLocal
@export var network_manager: NetworkManager

func _ready() -> void:
	network_manager.start_player_stream(_on_player_updated)
	local_player.start_local_player_sync_loop(network_manager.write_player)

func _on_player_updated(players: Array[PlayerData]) -> void:
	print(players)
