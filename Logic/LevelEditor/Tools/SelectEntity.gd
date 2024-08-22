class_name SelectEntityTool extends Tool

var selected_tile: Tile = null
var entity_idx: int = 0

var inspector: Inspector

func _selected():
	pass
	
func _deselected():
	pass

func _apply(level: Level, tile: Tile, eitorUI: EditorUI):
	_set_tile(level, tile, eitorUI.ent_active)

func _drag(_level: Level, tile: Tile, eitorUI: EditorUI):
	pass

func _set_tile(level: Level, tile: Tile, ent_active: EntityType):
	# for now just extract the exported properties of the first entity,
	# or just even the name
	# later we will want to cycle
	if tile == selected_tile:
		pass
	selected_tile = tile
	if len(tile.entities) == 0:
		print("no ents")
		return
	var entity: Entity = tile.entities[entity_idx]
	assert(inspector != null, "Inspector path must be set to use this SelectEntityTool.")
	inspector.inspect_entity(entity)
