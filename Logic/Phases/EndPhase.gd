extends AbstractPhase

func process_phase() -> bool:
	combat.round_ended.emit(combat.current_round)
	
	# Events
	combat.event.process_event()
	
	# All stat resets here
	combat.energy.pay(combat.energy.player_energy)
	
	if combat.enemies.is_empty():
		# TODO Game won
		combat.log.add("Game Won!")
		combat.animation.callback(combat.ui, "show_game_over", ["You won!"])
	
	combat.animation.callback(combat.ui, "set_status", ["Round ending ..."])
	
	combat.animation.camera_reach(combat.player.visual_entity)
	combat.animation.property(combat.camera, "player_input_enabled", true)
	
	combat.current_round += 1
	
	
	return false
