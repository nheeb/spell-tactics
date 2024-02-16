@tool
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


class DeckUtils:
	static func create_spell(spell_type: SpellType, combat: Combat) -> Spell:
		return Spell.new(spell_type, combat)
	
	static func load_spell(name: String, combat: Combat) -> Spell:
		return Spell.new(SpellType.load_from_file("res://Spells/AllSpells/%s.tres" % name), combat)
	
	static func load_spell_n_times(name: String, n: int, combat: Combat) -> Array[Spell]:
		var spells: Array[Spell] = []
		for i in range(n):
			spells.append(load_spell(name, combat))
		return spells
		
	static func create_test_deck_serialized() -> Array[SpellState]:
		var spell_states: Array[SpellState] = []
		for i in create_test_deck(null):
			spell_states.append(i.serialize())
		return spell_states

	static func create_test_deck(combat: Combat) -> Array[Spell]:
		var spells: Array[Spell] = []
		spells.append_array(load_spell_n_times("MudArmor", 1, combat))
		spells.append_array(load_spell_n_times("AirMissile", 3, combat))
		spells.append_array(load_spell_n_times("Berserker", 200, combat))
		spells.append_array(load_spell_n_times("TrappingRoots", 2, combat))
		spells.append_array(load_spell_n_times("SummonBush", 1, combat))
		spells.append_array(load_spell_n_times("SporeFlight", 2, combat))
		spells.append_array(load_spell_n_times("Cyclone", 1, combat))
		spells.append_array(load_spell_n_times("SelfHeal", 2, combat))
		spells.append_array(load_spell_n_times("GrowingMycel", 2, combat))
		spells.append_array(load_spell_n_times("DeadlyDart", 1, combat))
		
		for spell in spells:
			spell.id = SpellID.new(Game.add_to_spell_count())
		
		spells.shuffle()
		
		return spells
		
	static func create_spell_list():
		# TODO
		pass
	
	static func deck_for_spell_testing(combat: Combat) -> Array[Spell]:
		var spells: Array[Spell] = []
		for spell_type in Game.testing_deck:
			spell_type._on_load()
			spells.append(create_spell(spell_type, combat))
		for spell in spells:
			spell.id = SpellID.new(Game.add_to_spell_count())
		return spells

func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

func random_hash(length:int, chars := "abcdefghijklmnopqrstuvwxyz") -> String:
	var word: String = ""
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

func has_int_flag(flags: int, target_flag: int) -> bool:
	return (flags & target_flag) == target_flag

func add_int_flag(flags: int, target_flag: int) -> int:
	return flags | target_flag

func remove_int_flag(flags: int, target_flag: int) -> int:
	return flags & (~target_flag)
