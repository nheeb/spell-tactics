extends SpellLogic

func casting_effect() -> void:
	target_enemy.inflict_damage_with_visuals(2)
	combat.player.inflict_heal_with_visuals(2)

func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	for enemy in _target.get_enemies():
		if enemy.is_wounded():
			return true
	return false
