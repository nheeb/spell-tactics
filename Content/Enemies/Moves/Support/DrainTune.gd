extends EnemyActionLogic

func get_top_energy_tiles(origin: Tile, _range := 1, count := -1) -> Array[Tile]:
	var surrounding := origin.get_surrounding_tiles(_range)
	var drainable := surrounding.filter(
		func (t: Tile):
			return t.is_drainable()
	)
	drainable.sort_custom(
		func (a: Tile, b: Tile):
			return a.get_drainable_energy().size() >= b.get_drainable_energy().size()
	)
	if count > 0:
		return drainable.slice(0, count)
	else:
		return drainable

func _execute():
	var target_tiles := get_top_energy_tiles(combat.player.current_tile, 2, 3)
	var all_entities := []
	for tile in target_tiles:
		all_entities.append_array(tile.entities)
	
	await combat.action_stack.set_active_flavor(
		ActionFlavor.new().set_owner(enemy)
			.add_tag(ActionFlavor.Tag.Drain)
			.add_target_array(target_tiles)
			.add_target_array(all_entities)
			.finalize(combat)
	)
	
	combat.animation.say(enemy.visual_entity, "\"No energy for you!\"") \
		.set_duration(.6)
	combat.animation.camera_reach(combat.player) \
		.set_duration(.6)
	combat.animation.wait(.6)
	for tile in target_tiles:
		combat.animation.effect(VFX.HEX_RINGS, combat.player.current_tile, \
			 {"color": Color.RED}).set_flag_with()
	combat.animation.wait()
	for tile in target_tiles:
		combat.animation.effect(
			VFX.BILLBOARD_PROJECTILE, enemy,
			{"texture_name": "notes", "target": tile.node3d}
		).set_flag_extend()
	combat.animation.wait()
	for tile in target_tiles:
		for entity in tile.entities:
			if entity.is_drainable():
				await combat.action_stack.process_callable(entity.drain)
			elif entity.type.is_terrain:
				combat.animation.callable(entity.visual_entity.visual_drain).set_flag_with()

func _is_possible(enemy_tile: Tile) -> bool:
	return get_top_energy_tiles(combat.player.current_tile, 2).size() >= 3
