extends AbstractPhase

################
## DEPRECATED ##
################

func process_phase() -> bool:
	push_error("Processing deprecated phase: Pass")
	combat.animation.callback(combat.ui, "set_status", ["Player passed ..."])
	return false
