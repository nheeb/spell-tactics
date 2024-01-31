extends AbstractPhase

func process_phase() -> bool:
	combat.round_ended.emit(combat.current_round)
	combat.event.process_event()
	combat.animation.callback(combat.ui, "set_status", ["Round ending ..."])
	
	combat.animation.camera_reach(combat.player.visual_entity)
	combat.animation.property(combat.camera, "player_input_enabled", true)
	
	combat.current_round += 1
	
	
	return false
