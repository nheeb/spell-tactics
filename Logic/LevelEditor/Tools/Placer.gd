
class_name Placer extends Tool

func _selected():
	pass
	
func _deselected():
	pass

func _apply(level: Level, tile: Tile, eitorUI: EditorUI):
	_set_tile(level, tile, eitorUI.ent_active)

func _drag(_level: Level, tile: Tile, eitorUI: EditorUI):
	pass

func _set_tile(level: Level, tile: Tile, ent_active: EntityType):
	if not tile.has_entity(ent_active):  # prevent duplicate entities
		level.entities.create(tile.location, ent_active)
	