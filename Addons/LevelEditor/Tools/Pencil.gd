class_name Pencil extends Tool

var _active_set: Array[Tile] = []

func _selected():
	pass
	
func _deselected():
	pass

func _apply(editor: Editor, tile: Tile, placement_active: EntityType):
	_active_set = [tile]
	_set_tile(editor, tile, placement_active)

func _drag(editor: Editor, tile: Tile, placement_active: EntityType):
	if _active_set.has(tile):
		return
	_active_set.append(tile)
	_set_tile(editor, tile, placement_active)

func _set_tile(editor: Editor, tile: Tile, placement_active: EntityType):
	var current_terrain = editor.level.get_terrain(tile.r, tile.q)
	if current_terrain != null:
		editor.level.remove_entity(tile.r, tile.q, current_terrain)
	if placement_active != null:
		editor.level.create_entity(tile.r, tile.q, placement_active)
	
