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
			c.layers = layers

func spawn_instance(packed_scene: PackedScene, position: Vector3, parent: Node = null) -> Node3D:
	var new_obj = packed_scene.instantiate()
	if parent == null:
		Game.world.add_child(new_obj)
	else:
		parent.add_child(new_obj)
	new_obj.global_position = position
	return new_obj


# ----- Hex functions -----
func cube_add(r1, q1, s1, r2, q2, s2) -> Vector3i:
	return Vector3i(r1 + r2, q1 + q2, s1 + s2)
	
func axial_add():
	pass


## Returns an array with possible payment arrangement if possible or false if not
func is_energy_cost_payable(_bank: Array[Game.Energy], _cost: Array[Game.Energy]):
	var bank := _bank.duplicate(false)
	var cost := _cost.duplicate()
	var possible_payment : Array[Game.Energy] = []
	for e in cost:
		if e != Game.Energy.Any:
			if e in bank:
				possible_payment.append(e)
				bank.erase(e)
			else:
				return false
		else:
			if not bank.is_empty():
				possible_payment.append(bank.pop_front())
			else:
				return false
	return possible_payment

func pay_energy(bank: Array[Game.Energy], payment: Array[Game.Energy]):
	for e in payment:
		if e in bank:
			bank.erase(e)
		else:
			printerr("Non existing energy was payed.")
