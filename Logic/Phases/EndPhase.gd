extends AbstractPhase

func process_phase() -> bool:
	combat.ui_utility.set_debug_status("Round ending ...")
	return false
