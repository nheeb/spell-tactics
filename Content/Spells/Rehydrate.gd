extends SpellLogic

func is_target_valid(target: Variant, requirement: TargetRequirement) -> bool:
	for enemy in target.get_enemies():
		if enemy.get_status("Wet"):
			return true
	return false

func casting_effect() -> void:
	for enemy in target_enemies:
		enemy = enemy as EnemyEntity
		if enemy.get_status_effect("Wet"):
			enemy.remove_status("Wet")
	combat.energy.gain(EnergyStack.string_to_energy("H"), combat.player)
	combat.cards.draw()
	combat.cards.draw()
