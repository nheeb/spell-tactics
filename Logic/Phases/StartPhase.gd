extends AbstractPhase

## Start phase -> Drawing hand cards
func process_phase() -> bool:
	combat.animation.callback(combat.ui, "set_status", ["Drawing hand cards..."])
	combat.animation.wait(.5)
	combat.cards.draw_to_hand_size()
	
	combat.energy.drains_done_this_turn = 0
	var drains_left : int = combat.player.traits.max_drains - combat.energy.drains_done_this_turn
	combat.animation.callback(combat.ui, "set_drains_left", [drains_left])
	
	return false
