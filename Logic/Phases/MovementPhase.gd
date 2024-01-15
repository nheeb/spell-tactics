extends AbstractPhase

func process_phase() -> bool:
	combat.animation_queue.append(AnimationObject.new(combat.ui, "set_status", ["Make your movement!"]))
	print("ready to move")
	return true
