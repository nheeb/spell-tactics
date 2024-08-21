class_name SpellPhase extends AbstractPhase

func process_phase() -> void:
	combat.animation.callback(combat.player.visual_entity, "start_idling") # was in movement phase before

	combat.animation.callback(combat.ui, "set_status", ["Drain tiles and Cast your spells!"])
	
	# unlock all actives that are available once per round
	for active in combat.actives:
		if active.is_limited_per_round():
			active.refresh_uses_left()

func needs_user_input_to_proceed() -> bool:
	return true
