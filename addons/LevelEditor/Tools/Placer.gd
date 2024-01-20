@tool
class_name Placer extends Tool

func _selected():
	pass
	
func _deselected():
	pass

func _apply(editor: GridLevelEditor, tile: Tile, eitorUI: EditorUI):
	_set_tile(editor, tile, eitorUI.ent_active)

func _drag(editor: GridLevelEditor, tile: Tile, eitorUI: EditorUI):
	pass

func _set_tile(editor: GridLevelEditor, tile: Tile, ent_active: EntityType):
	editor.level.create_entity(tile.r, tile.q, ent_active)
	
