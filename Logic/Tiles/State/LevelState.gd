class_name LevelState extends Resource

@export var tiles: Array[TileState]
# columns for initiating the 2D tile array
@export var rows: int
@export var columns: int


func deserialize() -> Level:
	var level := Level.new()
	level.init_tiles_array(rows, columns)
	
	var tile: Tile
	for tile_data in tiles:
		tile = tile_data.deserialize(rows, columns)
		level.add_child(tile)
		level.tiles[tile_data.r][tile_data.q] = tile
	return level
