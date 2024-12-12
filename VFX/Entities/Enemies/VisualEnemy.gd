
class_name VisualEnemy extends VisualEntity

func on_movement_visuals(tile: Tile) -> void:
	# rotate player model so it faces the target tile
	var movement_direction = global_position.direction_to(tile.global_position)
	var relative_forward: Vector3 = -basis.z
	
	# rotate by difference between forward direction and movement direction
	rotate_y(relative_forward.signed_angle_to(movement_direction, Vector3.UP))
