extends AbstractPhase

## Start phase -> Drawing hand cards
func process_phase() -> bool:
	combat.animation_queue.append(AnimationObject.new(Game.combat_ui, "set_status", ["Drawing hand cards..."]))
	combat.animation_queue.append(AnimationWait.new(.5))
	combat.card_utility.draw_to_hand_size()
	return false
