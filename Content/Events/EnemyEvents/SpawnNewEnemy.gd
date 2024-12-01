extends EnemyEventLogic

## ACTION
func _on_discover():
	var tile := get_spawner_tile()
	if tile == null:
		tile = get_free_tile_near_enemy()
	data_store_reference("tile", tile)
	combat.animation.camera_reach(tile)
	combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.RED})

func _on_hover(hovering: bool) -> void:
	if hovering:
		var tile := data_resolve_reference("tile") as Tile
		if tile:
			combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.RED})

func _on_activate() -> void:
	var type: EnemyEntityType = event.data.get("enemy_type") as EnemyEntityType
	assert(type)
	var tile := data_resolve_reference("tile") as Tile
	if tile != null and tile.is_blocked():
		tile = null
	if tile == null:
		tile = get_spawner_tile()
	if tile == null:
		tile = get_free_tile_near_enemy()
	var new_enemy = type.create_entity(combat, tile)
	await combat.action_stack.wait()
	combat.enemies.append(new_enemy)
	await combat.action_stack.wait()
	combat.animation.camera_reach(new_enemy.current_tile)
	combat.animation.effect(VFX.HEX_RINGS, new_enemy.visual_entity, {"color": Color.RED}) \
		.set_duration(.3)
	combat.animation.show(new_enemy.visual_entity)
	event.finish()
	return

const SPAWNER = preload("res://Content/Entities/EnemySpawner.tres")

func get_spawner_tile() -> Tile:
	var spawner_tiles := combat.level.find_all_tiles_with(SPAWNER)
	spawner_tiles.shuffle()
	for tile in spawner_tiles:
		if not tile.is_blocked():
			return tile
	return null

func get_free_tile_near_enemy() -> Tile:
	for enemy in combat.get_all_enemies():
		for tile in enemy.current_tile.get_surrounding_tiles():
			if tile.is_blocked() or tile == combat.player.current_tile:
				continue
			return tile
	return null
