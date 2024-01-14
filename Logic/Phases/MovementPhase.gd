extends AbstractPhase

func process_phase() -> bool:
	combat.animation_queue.append(AnimationObject.new(Game.combat_ui, "set_status", ["Make your movement!"]))
	return true
