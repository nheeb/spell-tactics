extends AbstractPhase

## Start phase -> Drawing hand cards
func process_phase() -> bool:
	combat.animation.callback(combat.ui, "set_status", ["Drawing hand cards..."])
	combat.animation.wait(.5)
	combat.cards.draw_to_hand_size()
	return false
