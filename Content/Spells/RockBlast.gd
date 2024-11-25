extends SpellLogic

func execute() -> void:
	target_enemy.inflict_damage_with_visuals(
		1 + min(target_enemy.armor, 2), true
	)
