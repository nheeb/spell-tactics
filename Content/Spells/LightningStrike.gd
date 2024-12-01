extends SpellLogic

func execute() -> void:
	var base_damage := 3
	for enemy in target_enemies:
		if enemy.get_status("Wet"):
			enemy.inflict_damage_with_visuals(2*base_damage)
		else:
			enemy.inflict_damage_with_visuals(1*base_damage)
