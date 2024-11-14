extends SpellLogic

func casting_effect() -> void:
	var base_damage := 3
	target = target as Tile
	for enemy in target.get_enemies():
		enemy = enemy as EnemyEntity
		if enemy.get_status("Wet"):
			enemy.inflict_damage_with_visuals(2*base_damage)
		else:
			enemy.inflict_damage_with_visuals(1*base_damage)

#func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	#for enemy in _target.get_enemies():
		#enemy = enemy as EnemyEntity
		#return enemy.get_status("Wet") != null
	#return false
