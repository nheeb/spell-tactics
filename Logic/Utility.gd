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

## Reduces a new Array whith the Energy being reduced
func pay_energy(_bank: Array[Game.Energy], payment: Array[Game.Energy]) -> Array[Game.Energy]:
	var bank := _bank.duplicate(false)
	for e in payment:
		if e in bank:
			bank.erase(e)
		else:
			printerr("Non existing energy was payed.")
			return []
	return bank

var energy_to_letter := {
	Game.Energy.Life: "L",
	Game.Energy.Decay: "D",
	Game.Energy.Matter: "S",
	Game.Energy.Water: "W",
	Game.Energy.Flow: "F",
	Game.Energy.Any: "X",
}

var letter_to_energy := {
	"L": Game.Energy.Life,
	"D": Game.Energy.Decay,
	"S": Game.Energy.Matter,
	"W": Game.Energy.Water,
	"F": Game.Energy.Flow,
	"X": Game.Energy.Any,
}

func energy_to_string(energy: Array[Game.Energy]) -> String:
	return energy.reduce(func(x, y): return x + energy_to_letter[y], "")

func string_to_energy(string: String) -> Array[Game.Energy]:
	string = string.to_upper()
	var array : Array[Game.Energy] = []
	for c in string:
		if c in letter_to_energy.keys():
			array.append(letter_to_energy[c])
	return array

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
		
	
