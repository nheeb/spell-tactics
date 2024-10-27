extends EnemyActionLogic

func _execute():
	var start_tile := enemy.current_tile
	combat.animation.say(enemy, "ROCKET PUNCH!")
	var tiles_in_the_way := combat.level.get_line(
		enemy.current_tile, target_entity.current_tile
	)
	if tiles_in_the_way.size() > 1:
		tiles_in_the_way.pop_back()
		var destination := tiles_in_the_way[-1]
		combat.movement.move_entity(enemy, destination)
	(target_entity as HPEntity).inflict_damage_with_visuals(3)
	combat.movement.apply_knockback(
		target_entity,
		start_tile.direction_to(target_entity.current_tile)
	)

func _is_possible(enemy_tile: Tile) -> bool:
	var tiles_in_the_way := combat.level.get_line(
		enemy_tile, target_entity.current_tile
	)
	for tile in tiles_in_the_way:
		if tile.is_obstacle():
			return false
	return true
