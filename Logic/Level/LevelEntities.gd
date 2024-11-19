class_name LevelEntities extends Object

var _level: Level

func _init(level: Level):
	_level = level
	
func create(location: Vector2i, entity_type: EntityType, create_with_active_visuals := true) -> Entity:
	assert(false, "Deprecated")
	return entity_type.create_entity(_level.combat, _level.get_tile(location))

func fill_entity(entity_type: EntityType):
	for tile in _level.get_all_tiles():
		var coord = Vector2i(tile.r, tile.q)
		create(coord, entity_type)
	
func remove(location: Vector2i, entity: Entity):
		# commented out with the LevelEditor change from tool to scene - Nils
		#if not Engine.is_editor_hint():
			#push_error("Level remove_entity: This method maybe shouldn't be executed in the running game.")
		
		var tile = _level.get_tile(location)
		var pos = tile.entities.find(entity)
		tile.entities.remove_at(pos)
		if entity.visual_entity:
			entity.visual_entity.queue_free()

func get_terrain(location: Vector2i) -> Entity:
	var tile = _level.get_tile(location)
	for entity in tile.entities:
		if entity.type.is_terrain:
			return entity
	return null

func get_all_entities() -> Array[Entity]:
	var all_entities: Array[Entity] = []
	for tile in _level.get_all_tiles():
		all_entities.append_array(tile.entities)
	all_entities.append_array(_level.graveyard)
	return all_entities

## Does not include entities in the graveyard
func get_all_active_entities() -> Array[Entity]:
	var all_entities: Array[Entity] = []
	for tile in _level.get_all_tiles():
		all_entities.append_array(tile.entities)
	return all_entities
