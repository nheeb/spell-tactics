extends EnemyActionLogic

func _execute():
	var start_tile := enemy.current_tile
	combat.animation.say(enemy, "ROCKET PUNCH!")
	var tiles_in_the_way := combat.level.get_line(
		enemy.current_tile, target_entity.current_tile
	)
<<<<<<< HEAD
	
	var obstacle_tile
	var previous_tile
	
	for tile in tiles_in_the_way:
		combat.animation.effect(VFX.HEX_COLOR, tile)
		if tile.is_obstacle():
			tile.get_obstacle_layers()
			obstacle_tile = tile
			break
		previous_tile = tile  # Update previous tile if current one is not an obstacle
	
	var blocking_entity: Entity = null
	
	if obstacle_tile:
		for ent in obstacle_tile.entities:
			var cover := ent.type.cover_value as int
			if cover >= 1:
				blocking_entity = ent
				break
	
	if obstacle_tile:
		var destination := previous_tile as Tile
		combat.movement.move_entity(enemy, destination)

		if blocking_entity:
			blocking_entity.die()
	elif tiles_in_the_way.size() > 1:
		tiles_in_the_way.pop_back()
		var destination := tiles_in_the_way[-1]
		combat.movement.move_entity(enemy, destination)
		(target_entity as HPEntity).inflict_damage_with_visuals(3)
		combat.movement.apply_knockback(
			target_entity,
			start_tile.direction_to(target_entity.current_tile)
		)

func _is_possible(enemy_tile: Tile) -> bool:
	
	#var tiles_in_the_way := combat.level.get_line(
		#enemy_tile, target_entity.current_tile
	#)
	#for tile in tiles_in_the_way:
		#if tile.is_obstacle():
			#tile.get_obstacle_layers()
			#return false
=======
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
>>>>>>> main
	return true
