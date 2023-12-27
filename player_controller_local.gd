extends Node2D

class_name PlayerControllerLocal

var player_data: PlayerData

func _ready() -> void:
	player_data = PlayerData.new(str(randi_range(1000, 9999)), "FFFFFF")
	player_data.position_x = global_position.x
	player_data.position_y = global_position.y

func start_local_player_sync_loop(callback: Callable):
	while true:
		player_data.position_x = global_position.x
		player_data.position_y = global_position.y
		await callback.call(player_data)
		await get_tree().process_frame
