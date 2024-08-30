class_name Erase extends Tool

var _active_set: Array[Tile] = []

func _selected():
	pass
	
func _deselected():
	pass

func _apply(level: Level, tile: Tile, eitorUI: EditorUI):
	_active_set = [tile]
	_set_tile(level, tile, eitorUI.placement_active)

func _drag(_level: Level, tile: Tile, eitorUI: EditorUI):
	if _active_set.has(tile):
		return
	_active_set.append(tile)
	_set_tile(_level, tile, eitorUI.placement_active)

func _set_tile(level: Level, tile: Tile, placement_active: EntityType):
	var entities = level.tiles[tile.r][tile.q].entities
	for ent in entities:
		if not ent.type.is_terrain:
			level.entities.remove(tile.location, ent)
	
