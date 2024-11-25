extends SpellLogic

func execute() -> void:
	for enemy in target_enemies:
		enemy.inflict_damage_with_visuals(3)
		enemy.apply_status(Preloaded.STATUS_WET)
		combat.movement.apply_knockback(enemy, \
				combat.player.current_tile.direction_to(enemy.current_tile), 2)
