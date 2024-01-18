class_name Lower extends Tool

var _active_set: Array[Tile] = []

func _selected():
	pass
	
func _deselected():
	pass

func _apply(editor: LevelEditor, tile: Tile, placement_active: EntityType):
	_active_set = [tile]
	_set_tile(tile)

func _drag(editor: LevelEditor, tile: Tile, placement_active: EntityType):
	if _active_set.has(tile):
		return
	_active_set.append(tile)
	_set_tile(tile)

func _set_tile(tile: Tile):
	tile.global_position += Vector3.DOWN * 0.1
	for entity in tile.entities:
		if entity.visual_entity:
			entity.visual_entity.global_position += Vector3.DOWN * 0.1
	
