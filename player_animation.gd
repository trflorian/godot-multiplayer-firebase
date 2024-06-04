extends CollisionShape2D

static func _get_sprite_frame(look_dir: int, is_walking: bool, animation_frame: int) -> int:
	var sprite_frame = look_dir * 4
	if is_walking:
		sprite_frame += 2
	sprite_frame += animation_frame
	return sprite_frame
