class_name SelectEntityTool extends Tool

var selected_tile: Tile = null
var entity_idx: int = 0

func _selected():
	pass
	
func _deselected():
	pass

func _apply(level: Level, tile: Tile, eitorUI: EditorUI):
	_set_tile(level, tile, eitorUI.ent_active)

func _drag(_level: Level, tile: Tile, eitorUI: EditorUI):
	pass

func _set_tile(level: Level, tile: Tile, ent_active: EntityType):
	level.entities.create_entity(tile.location, ent_active)
