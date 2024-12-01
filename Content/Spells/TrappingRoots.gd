extends SpellLogic

## Here should be the effect
func execute() -> void:
	for enemy in target_enemies:
		#enemy.apply_status_effect(SnareEffect.new(2))
		enemy.apply_status(Preloaded.STATUS_SNARE)
