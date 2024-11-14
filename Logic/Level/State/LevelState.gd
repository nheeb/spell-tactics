class_name LevelState extends Resource

@export var tiles: Array[TileState]
@export var graveyard: Array[EntityState]
# columns for initiating the 2D tile array
@export var rows: int
@export var columns: int

const LEVEL = preload("res://Logic/Level/Level.tscn")
const PLAYER_TYPE = preload("res://Content/Player/PlayerResource.tres")

func deserialize(combat: Combat) -> Level:
	var level := LEVEL.instantiate()
	level.combat = combat
	combat.level = level
	level._ready()
	level.init_tiles_array(rows, columns)
	
	var tile: Tile
	for tile_data in tiles:
		tile = tile_data.deserialize(combat)
		level.add_child(tile.tile3d)
		level.update_visual_entities(tile)
		level.tiles[tile.r][tile.q] = tile
	
	var player_ent: PlayerEntity = level.find_entity_type(PLAYER_TYPE)
	if player_ent != null:
		level.player = player_ent
	
	level.graveyard.append_array(graveyard.map(func (x): return x.deserialize(combat)))
	
	return level
