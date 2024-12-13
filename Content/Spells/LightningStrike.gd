extends SpellLogic

func execute() -> void:
	var base_damage := 3
	var bonus_damage := 2
	for enemy in target_enemies:
		if enemy.get_status("Wet"):
			enemy.inflict_damage_with_visuals(base_damage + bonus_damage)
		else:
			enemy.inflict_damage_with_visuals(base_damage)
