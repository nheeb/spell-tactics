extends SpellLogic

func execute() -> void:
	assert(target_tiles.size() == 2)
	var source_tile := target_tiles[0]
	var destination_tile := target_tiles[1]
	var ents := target_tile.entities.filter(func(e: Entity): return not e.type.is_terrain)
	
	## Get destination (near the origin & prefering a tile without obstacle)
	#var possible_tiles := Utility.array_sorted(
		#Utility.array_shuffled(combat.player.current_tile.get_surrounding_tiles()),
		#func (tile: Tile):
			#var score := tile.distance_to(target_tile)
			#if tile.is_blocked() or tile == combat.player.current_tile:
				#score += 10
			#return score
	#)
	#var destination : Tile = possible_tiles.front() as Tile
	
	for ent in ents:
		combat.movement.blink_entity(ent, destination_tile).set_flag_with()
	
	combat.castables.get_active_from_name("Drain").add_to_bonus_uses(1)

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
