extends AbstractPhase

func process_phase() -> bool:
	combat.animation.callback(combat.ui, "set_status", ["Player passed ..."])
	return false
