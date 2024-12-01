class_name PADeselectTile extends PlayerAction

var tile: Tile

func _init(_tile: Tile) -> void:
	tile = _tile
	action_string = "Deselect Tile <%s>" % tile

func is_valid(combat: Combat) -> bool:
	if combat.input.current_castable:
		return tile in combat.input.current_castable.details.get_target_array()
	return false

func execute(combat: Combat) -> void:
	combat.input.current_castable.remove_target_from_details(tile)

func on_fail(combat: Combat) -> void:
	if combat.input.current_castable:
		await combat.action_stack.process_player_action(PADeselectCastable.new())
