extends AbstractPhase

func process_phase() -> bool:
	combat.event.process_event()
	combat.animation.callback(combat.ui, "set_status", ["Round ending ..."])
	return false
