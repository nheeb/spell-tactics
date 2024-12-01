class_name TerrainPlace extends Tool

var _active_set: Array[Tile] = []

func _selected():
	pass
	
func _deselected():
	pass

func _apply(level: Level, tile: Tile, eitorUI: EditorUI):
	_active_set = [tile]
	_set_tile(level, tile, eitorUI.placement_active)

func _drag(level: Level, tile: Tile, eitorUI: EditorUI):
	if _active_set.has(tile):
		return
	_active_set.append(tile)
	_set_tile(level, tile, eitorUI.placement_active)

func _set_tile(level: Level, tile: Tile, placement_active: EntityType):
	var current_terrain = level.entities.get_terrain(tile.location)
	if current_terrain != null:
		level.entities.remove(tile.location, current_terrain)
	if placement_active != null:
		placement_active.create_entity(level.combat, tile)
		#level.entities.create(tile.location, placement_active)
