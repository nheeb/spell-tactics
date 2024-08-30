extends EnemyEventLogic

const GOBLIN = preload("res://Entities/Enemies/Goblin.tres")

func _on_activate() -> void:
	for enemy in combat.get_all_enemies():
		for tile in enemy.current_tile.get_surrounding_tiles():
			if bool(tile.get_obstacle_layers() & GOBLIN.obstacle_mask) or tile == combat.player.current_tile:
				continue
			var location = tile.location
			var goblin = combat.level.entities.create(location, GOBLIN, false)
			combat.enemies.append(goblin)
			combat.animation.camera_reach(goblin.visual_entity)
			combat.animation.wait(.4)
			combat.animation.show(goblin.visual_entity)
			combat.animation.effect(VFX.HEX_RINGS, goblin.visual_entity, {"color": Color.RED})
			event.finish()
			return
