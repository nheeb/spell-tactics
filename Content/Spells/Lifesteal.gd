extends SpellLogic

func execute() -> void:
	target_enemy.inflict_damage_with_visuals(2)
	combat.player.inflict_heal_with_visuals(2)

func is_target_valid(target: Variant, requirement: TargetRequirement, _actor: Entity) -> bool:
	for enemy in target.get_enemies():
		if enemy.is_wounded():
			return true
	return false
