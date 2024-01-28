extends AbstractPhase

func process_phase() -> bool:
	combat.event.process_event()
	combat.animation.callback(combat.ui, "set_status", ["Round ending ..."])
	
	combat.animation.camera_reach(combat.player.visual_entity)
	combat.animation.property(combat.camera, "player_input_enabled", true)
	
	return false
