
class_name Raise extends Tool

var _active_set: Array[Tile] = []

func _selected():
	pass
	
func _deselected():
	pass

func _apply(_level: Level, tile: Tile, eitorUI: EditorUI):
	_active_set = [tile]
	_set_tile(tile)

func _drag(_level: Level, tile: Tile, eitorUI: EditorUI):
	if _active_set.has(tile):
		return
	_active_set.append(tile)
	_set_tile(tile)

func _set_tile(tile):
	tile.global_position += Vector3.UP * 0.4
	for entity in tile.entities:
		if entity.visual_entity:
			entity.visual_entity.global_position += Vector3.UP * 0.4
	
