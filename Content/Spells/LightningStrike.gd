extends SpellLogic

func execute() -> void:
	var base_damage := 3
	target = target as Tile
	for enemy in target.get_enemies():
		enemy = enemy as EnemyEntity
		if enemy.get_status("Wet"):
			enemy.inflict_damage_with_visuals(2*base_damage)
		else:
			enemy.inflict_damage_with_visuals(1*base_damage)
		
