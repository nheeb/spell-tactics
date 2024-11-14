extends SpellLogic

func casting_effect() -> void:
	var ent := get_non_terrain_entity_with_highest_energy(target_tile)
	var direction := combat.player.current_tile.direction_to(target_tile)
	var destination := combat.player.current_tile.step_in_direction(direction)
	combat.movement.blink_entity(ent, destination)
	
	var drain_active := Utility.array_safe_get(
		combat.actives.filter(
			func (a: Active): return a.type.internal_name == "Drain"
		), 0) as Active
	drain_active.add_to_bonus_uses(1)

func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	return get_non_terrain_entity_with_highest_energy(_target) != null

func get_non_terrain_entity_with_highest_energy(tile: Tile) -> Entity:
	var entities := tile.entities.duplicate()
	entities = entities.filter(
		func (entity: Entity):
			return entity.is_drainable() and not entity.type.is_terrain
	)
	entities.sort_custom(
		func (a: Entity, b: Entity):
			return a.energy.size() > b.energy.size()
	)
	if not entities.is_empty():
		return entities[0]
	return null
