extends Node

func remove_y_value(pos: Vector3) -> Vector3:
	pos.y = 0.0
	return pos

func no_y_normalized(vec: Vector3) -> Vector3:
	return remove_y_value(vec).normalized()

func y_plane_dist(pos1: Vector3, pos2: Vector3) -> float:
	return remove_y_value(pos1).distance_to(remove_y_value(pos2))

func clamp_map(value: float, istart: float, istop: float, ostart: float, ostop: float) -> float:
	value = clamp(value, istart, istop)
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))

func align_node(node: Node3D, local_direction: Vector3, target_global_direction: Vector3):
	var current_global_direction := node.global_position.direction_to(node.to_global(local_direction))
	var cross_direction := current_global_direction.cross(target_global_direction).normalized()
	if cross_direction.is_normalized():
		var rotation_angle := current_global_direction.signed_angle_to(target_global_direction, cross_direction)
		node.rotate(cross_direction, rotation_angle)

func recursive_set_light_layers(node: Node, layers: int):
	for c in node.get_children():
		recursive_set_light_layers(c, layers)
		if c is VisualInstance3D:
			(c as VisualInstance3D).layers = layers

# ----- Hex functions -----
func cube_add(r1: int, q1: int, s1: int, r2: int, q2: int, s2: int) -> Vector3i:
	return Vector3i(r1 + r2, q1 + q2, s1 + s2)
	
func axial_add():
	pass

func random_index_of_scores(scores: Array[float]) -> int:
	if scores.is_empty():
		printerr("Random index: Empty list")
		return -1
	var total_size : float = scores.reduce(func(a,b): return a + b, 0.0)
	if total_size == 0.0:
		printerr("Random index: Only Zero entries")
		return -1
	var random_value := randf_range(0.0, total_size)
	for i in range(scores.size()):
		random_value -= scores[i]
		if random_value < 0.0:
			return i
	printerr("Random index: Something went wrong")
	return -1

## the hit chance should be between 0 and 100
func random_hit(hit_chance: float) -> bool:
	assert(hit_chance >= 0.0 and hit_chance <= 100.0)
	return randf() <= (hit_chance * 0.01)

## could maybe be put in Utils singleton
func rq_distance(r1: int, q1: int, r2: int, q2: int) -> int:
	return (abs(q1 - q2) 
			+ abs(q1 + r1 - q2 - r2)
			+ abs(r1 - r2)) / 2
			
func tile_distance(t1: Tile, t2: Tile) -> int:
	return rq_distance(t1.r, t1.q, t2.r, t2.q)
	
func entity_distance(e1: Entity, e2: Entity) -> int:
	assert(is_instance_valid(e1.current_tile) and is_instance_valid(e2.current_tile), 
		   "distance: entity has no tile")
	return tile_distance(e1.current_tile, e2.current_tile)
		
	
