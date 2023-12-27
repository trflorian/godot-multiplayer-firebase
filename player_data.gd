extends Object

class_name PlayerData

var player_id: String
var position_x: float
var position_y: float
var color: String

func to_dict() -> Dictionary:
	return {
		"player_id": player_id,
		"position_x": position_x,
		"position_y": position_y,
		"color": color
	}

func _init(_player_id: String, _color: String):
	player_id = _player_id
	color = _color
