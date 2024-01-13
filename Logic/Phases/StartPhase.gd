extends AbstractPhase

## Start phase -> Drawing hand cards
func process_phase() -> bool:
	combat.card_utility.draw_to_hand_size()
	return false
