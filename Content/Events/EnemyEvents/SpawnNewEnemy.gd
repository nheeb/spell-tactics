extends EnemyEventLogic

func _on_activate() -> void:
	var type: EnemyEntityType = event.params.get("enemy_type") as EnemyEntityType
	assert(type)
	for enemy in combat.get_all_enemies():
		for tile in enemy.current_tile.get_surrounding_tiles():
			if bool(tile.get_obstacle_layers() & type.obstacle_mask) or tile == combat.player.current_tile:
				continue
			var location = tile.location
			#var new_enemy = combat.level.entities.create(location, type, false)
			var new_enemy = type.create_entity(combat, tile)
			combat.enemies.append(new_enemy)
			combat.animation.camera_reach(new_enemy.visual_entity)
			combat.animation.wait(.4)
			combat.animation.show(new_enemy.visual_entity)
			combat.animation.effect(VFX.HEX_RINGS, new_enemy.visual_entity, {"color": Color.RED})
			event.finish()
			return
