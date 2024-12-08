class_name PASelectTile extends PlayerAction

var tile: Tile

func _init(_tile: Tile) -> void:
	tile = _tile
	action_string = "Select Tile <%s>" % tile

func is_valid(combat: Combat) -> bool:
	var castable := combat.input.current_castable
	if castable:
		var req := combat.input.current_castable.get_next_requirement()
		if req:
			if req.type == TargetRequirement.Type.Tile:
				return castable.is_target_valid(tile, req)
	return false

func execute(combat: Combat) -> void:
	combat.input.current_castable.add_target_to_details(tile)
	combat.input.current_castable.update_current_state()
	await combat.action_stack.wait()
	combat.action_stack.active_ticket.finish()
	await VisualTime.new_timer(.25).timeout
	combat.action_stack.process_player_action(PAActivateCastable.new(false))

func on_fail(combat: Combat) -> void:
	pass
