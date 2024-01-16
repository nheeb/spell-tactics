class_name Lower extends Tool

var _active_set: Array[Tile] = []

func _selected():
	pass
	
func _deselected():
	pass

func _apply(editor: Editor, tile: Tile):
	_active_set = [tile]
	_set_tile(tile)

func _drag(editor: Editor, tile: Tile):
	if _active_set.has(tile):
		return
	_active_set.append(tile)
	_set_tile(tile)

func _set_tile(tile):
	tile.global_position += Vector3.DOWN * 0.1
	
