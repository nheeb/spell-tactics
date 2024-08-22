class_name PASelectTile extends PlayerAction

const DESELECT_ON_FULL_TARGETS = true

var tile: Tile

func _init(_tile: Tile) -> void:
	tile = _tile
	action_string = "Select Tile <%s>" % tile

func is_valid(combat: Combat) -> bool:
	if combat.input.current_castable:
		var full := combat.input.current_castable.are_targets_full()
		if DESELECT_ON_FULL_TARGETS:
			if not combat.input.current_castable.targets.is_empty():
				full = false
		var suitable := combat.input.current_castable.is_target_possible(tile)
		var already_target := tile in combat.input.current_castable.targets
		return suitable and (not full) and (not already_target)
	return false

func execute(combat: Combat) -> void:
	if DESELECT_ON_FULL_TARGETS:
		var full := combat.input.current_castable.are_targets_full()
		if full:
			combat.input.process_action(PADeselectTile.new(
				combat.input.current_castable.targets[0]
			))
	combat.input.current_castable.add_target(tile)
	combat.action_stack.active_ticket.finish()
	await VisualTime.new_timer(.35).timeout
	# DANGER it should be ok to use process_player_action
	# since the ticket is finished
	combat.action_stack.process_player_action(PAActivateCastable.new(false))

func on_fail(combat: Combat) -> void:
	pass

