class_name PADeselectTile extends PlayerAction

var tile: Tile

func _init(_tile: Tile) -> void:
	tile = _tile
	action_string = "Deselect Tile <%s>" % tile

func is_valid(combat: Combat) -> bool:
	if combat.input.current_castable:
		if tile in combat.input.current_castable.targets:
			return true
	return false

func execute(combat: Combat) -> void:
	combat.input.current_castable.remove_target(tile)

func on_fail(combat: Combat) -> void:
	if combat.input.current_castable:
		combat.input.process_action(PADeselectCastable.new())

