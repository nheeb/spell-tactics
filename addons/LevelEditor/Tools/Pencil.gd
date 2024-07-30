@tool
class_name Pencil extends Tool

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
	var current_terrain = level.entities().get_terrain(tile.location)
	if current_terrain != null:
		level.entities().remove_entity(tile.location, current_terrain)
	if placement_active != null:
		level.entities().create_entity(tile.location, placement_active)
	
