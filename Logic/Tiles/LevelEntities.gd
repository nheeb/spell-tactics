@tool
class_name LevelEntities extends Object

var _level: Level

func _init(level: Level):
	_level = level
	
func create_entity(location: Vector2i, entity_type: EntityType) -> Entity:
	var tile = _level.get_tile(location)
	if tile.has_entity(entity_type):
		return

	var entity := entity_type.create_entity(_level.combat) as Entity
	
	entity.visual_entity.visible = true
	_level.visual_entities.add_child(entity.visual_entity)
	entity.visual_entity.owner = _level
	
	tile.add_entity(entity)
	if entity.visual_entity != null:
		entity.visual_entity.position = tile.position
		# TODO add logical entity
	
	# Create id for entity
	entity.id = EntityID.new(entity.type, _level.add_type_count(entity.type))
	
	return entity

func fill_entity(entity_type: EntityType):
	for tile in _level.get_all_tiles():
		var coord = Vector2i(tile.r, tile.q)
		create_entity(coord, entity_type)
	
func remove_entity(location: Vector2i, entity: Entity):
		if not Engine.is_editor_hint():
			printerr("Level remove_entity: This method maybe shouldn't be executed in the running game.")
		
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
