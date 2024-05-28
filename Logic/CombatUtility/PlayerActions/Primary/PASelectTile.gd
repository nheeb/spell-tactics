class_name PASelectTile extends PlayerAction

var tile: Tile

func _init(_tile: Tile) -> void:
	tile = _tile
	action_string = "Select Tile <%s>" % tile

func is_valid(combat: Combat) -> bool:
	if combat.input.current_castable:
		var full := combat.input.current_castable.are_targets_full()
		var suitable := combat.input.current_castable.is_target_possible(tile)
		var already_target := tile in combat.input.current_castable.targets
		return suitable and (not full) and (not already_target)
	return false

func execute(combat: Combat) -> void:
	combat.input.current_castable.add_target(tile)
	# TODO nitai tile highlight Visuals

func on_fail(combat: Combat) -> void:
	pass

