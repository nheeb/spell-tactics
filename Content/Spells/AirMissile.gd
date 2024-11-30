extends SpellLogic

func execute() -> void:
	for enemy in target_enemies:
		enemy.inflict_damage_with_visuals(2)
