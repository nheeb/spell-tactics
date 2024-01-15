extends AbstractPhase

func process_phase() -> bool:
	combat.animation_queue.append(AnimationObject.new(combat.ui, "set_status", ["Player passed ..."]))
	return false
