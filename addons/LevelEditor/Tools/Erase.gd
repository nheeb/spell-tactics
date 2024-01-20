@tool
class_name Erase extends Tool

var _active_set: Array[Tile] = []

func _selected():
	pass
	
func _deselected():
	pass

func _apply(editor: GridLevelEditor, tile: Tile, eitorUI: EditorUI):
	_active_set = [tile]
	_set_tile(editor, tile, eitorUI.placement_active)

func _drag(editor: GridLevelEditor, tile: Tile, eitorUI: EditorUI):
	if _active_set.has(tile):
		return
	_active_set.append(tile)
	_set_tile(editor, tile, eitorUI.placement_active)

func _set_tile(editor: GridLevelEditor, tile: Tile, placement_active: EntityType):
	var entities = editor.level.tiles[tile.r][tile.q].entities
	for ent in entities:
		if not ent.type.is_terrain:
			editor.level.remove_entity(tile.r, tile.q, ent)
	
