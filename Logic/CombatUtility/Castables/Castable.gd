class_name Castable extends Object

var combat: Combat

var targets: Array[Tile]

var combat_persistant_properties := {}
var round_persistant_properties := {}

func get_effect_text() -> String:
	return "<Effect Text not implemented>"

func is_selectable() -> bool:
	return false

func is_castable() -> bool:
	return are_targets_castable()

## ACTION
func try_cast() -> void:
	await get_logic().try_cast()
	#combat.log.register_cast(self)

var selected := false
func select():
	selected = true
	reset_targets()
	get_logic()._on_select_deselect(true)
	update_current_state()

func deselect():
	selected = false
	reset_targets()
	for tile in combat.level.get_all_tiles():
		tile.set_highlight(get_type().target_possible_highlight, false)
		tile.set_highlight(get_type().target_selected_highlight, false)
	get_logic()._on_select_deselect(false)
	combat.ui.error_lines.clear()

func get_card() -> Card3D:
	return null

func get_logic() -> CastableLogic:
	return null

func get_type() -> CastableType:
	return null

var possible_targets : Array[Tile]
func is_target_possible(target: Tile) -> bool:
	return target in possible_targets

func is_target_suitable_as_next_target(target: Tile) -> bool:
	return get_logic()._is_target_suitable(target, targets.size())

func reset_targets() -> void:
	targets.clear()

func add_target(target: Tile) -> void:
	targets.append(target)
	target.set_highlight(get_type().target_selected_highlight, true)
	update_current_state()

func remove_target(target: Tile) -> void:
	targets.erase(target)
	target.set_highlight(get_type().target_selected_highlight, false)
	update_current_state()

func are_targets_full() -> bool:
	if get_type().target == CastableType.Target.None or \
							get_type().target_count_max == 0:
		return true
	var target_count := targets.size()
	if get_type().target_count_max < 0:
		return get_logic()._are_targets_full(targets)
	return target_count >= get_type().target_count_max

func are_targets_castable() -> bool:
	if get_type().target == CastableType.Target.None:
		if targets.is_empty():
			return true
		else:
			push_error("NoneTarget Castable has targets???")
	var target_count := targets.size()
	var logic_castable = get_logic()._are_targets_castable(targets)
	return target_count >= get_type().target_count_min and logic_castable

func get_possible_targets() -> Array[Tile]:
	var target_range = get_type().target_range
	var target_min_range = get_type().target_min_range
	var tiles: Array[Tile]
	if target_range != -1:
		tiles = combat.level.get_all_tiles_in_distance_of_tile(combat.player.current_tile, 
															   target_range)
	else:
		tiles = combat.level.get_all_tiles()
	if target_min_range != -1:
		var min_range_tiles = combat.level.get_all_tiles_with_min_distance_of_tile(combat.player.current_tile, target_min_range)
		tiles = tiles.filter(func (t): return t in min_range_tiles)

	if get_type().target == SpellType.Target.Enemy:
		tiles = tiles.filter(func(t): return t.has_enemy())
	elif get_type().target == SpellType.Target.TileWithoutObstacles:
		tiles = tiles.filter(func(t): return not(t.get_obstacle_layers() & EntityType.NAV_OBSTACLE_LAYER))
	elif get_type().target == SpellType.Target.Tag:
		tiles = tiles.filter(func(t): return get_type().target_tag in t.get_tags())
	elif get_type().target == SpellType.Target.Cone:
		var none : Array[Tile] = []
		return none
	elif get_type().target == SpellType.Target.None:
		var none : Array[Tile] = []
		return none
	tiles = tiles.filter(func(t): return is_target_suitable_as_next_target(t))
	return tiles 

## This calculates which targets are possible to choose in the current state.
func update_possible_targets() -> void:
	possible_targets = get_possible_targets()

## This updates all ui / highlights / possible targets.
func update_current_state() -> void:
	update_possible_targets()
	var highlight_possible := get_type().target_possible_highlight
	for tile in combat.level.get_all_tiles():
		tile.set_highlight(highlight_possible, false)
	for tile in possible_targets:
		tile.set_highlight(highlight_possible, true)
	
	combat.ui.error_lines.clear()
	if is_instance_valid(get_card()):
		get_card().set_glow(is_castable())
	else:
		push_error("Card for Castable visual update not found")
	update_target_ui()

func update_target_ui():
	if not are_targets_castable():
		if possible_targets.is_empty():
			combat.ui.error_lines.add("No suitable targets")
		else:
			combat.ui.error_lines.add("Select target tile(s)")

func get_reference_castable() -> CastableReference:
	return CastableReference.new(self)
