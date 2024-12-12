extends EnemyActionLogic

func _execute():
	var dmg := enemy.strength
	combat.attack.punch_animation(enemy, target_entity,)
	target_tile.inflict_damage_with_visuals(dmg)

func _is_possible(enemy_tile) -> bool:
	return target_tile.is_next_to(enemy_tile)
