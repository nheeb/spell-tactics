extends EnemyActionLogic

func _execute():
	var dmg : int = enemy.strength

	if combat.attack.enemy_punch(enemy, 0):
		combat.player.inflict_damage_with_visuals(dmg)

func _is_possible(enemy_tile) -> bool:
	return combat.player.current_tile.is_next_to(enemy_tile)
