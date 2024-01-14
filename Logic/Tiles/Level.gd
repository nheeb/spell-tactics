#@tool
class_name Level extends Node3D

## Different initialization functions should be implemented.
## For example initializing regular n-grid.
## Or loading a resource defining a map.
## Ideally, this would even work in a tool script so in-editor as well1
## We're using (r,q)-axial coordinates, for a reference see
## https://www.redblobgames.com/grids/hexagons/#coordinates-axial


## 2D Array of tiles, indexed with (r,q)
var tiles: Array[Array] = []  # Tile
var n_rows: int
var n_cols: int

func _ready() -> void:
	pass
	

var TileScene = preload("res://Logic/Tiles/Tile.tscn")
const Q_BASIS: Vector2 = Vector2(sqrt(3), 0)
const R_BASIS: Vector2 = Vector2(sqrt(3)/2, 3./2)
const ROCK_ENTITY := preload("res://Entities/Environment/Rock.tres")
const WATER_ENTITY := preload("res://Entities/Environment/Water.tres")
const PLAYER_ENTITY := preload("res://Entities/PlayerResource.tres")
func init_basic_grid(n: int):
	# The origin tile will have coordinates (r=n, q=n).
	# This makes it so the top-left tile will have coordinates 0,0 in the tiles 2D array
	# The origin tile will be centered at the position of the Level node.
	# initiate 2d Array, it will have dimensions (2n, 2n)
	for i in range(2*n + 1):
		tiles.append([])
		for j in range(2*n+1):
			tiles[i].append(null)

	for r in range(0, 2*n + 1):
		for q in range(0, 2*n + 1):
			# first off, check if this tile would have distance > n from origin
			# in that case continue and put null into the array position
			if tile_distance(r, q, n, n) > n: 
				continue

			# TODO put this into some create_tile method 
			var new_tile: Tile = TileScene.instantiate()
			add_child(new_tile)
			new_tile.owner = self
			var xz_translation: Vector2 = (r-n) * Q_BASIS + (q-n) * R_BASIS 
			new_tile.position = Vector3(xz_translation.x, 0.0, xz_translation.y)
			new_tile.get_node("DebugLabel").text = "(%s, %s)" % [r, q]
			new_tile.r = r
			new_tile.q = q
			tiles[r][q] = new_tile
	
	# let's add a rock to the center tile
	add_entity(3, 3, ROCK_ENTITY)
	add_entity(3, 4, WATER_ENTITY)
	add_entity(0, 6, PLAYER_ENTITY)
	
	n_rows = 2 * n + 1
	n_cols = 2 * n + 1
	
	# TODO finish implementing Entity to_state() 
	#to_state()
	
## Serialize the whole tile grid and all entities.
func to_state() -> LevelState:
	var level_state = LevelState.new()
	level_state.rows = n_rows
	level_state.columns = n_cols
	
	var tile_data: Array[TileData] = []
	var tile: Tile
	for r in range(0, n_rows):
		for q in range(0, n_cols):
			tile = tiles[r][q]
			if tile != null:
				tile_data.append(tile.to_state())
	
	return level_state

func add_entity(r: int, q: int, entity_type: EntityType) -> Entity:
	# should entities only be part of tiles or do we want a second data structure outside?
	# here, in Level
	if tiles[r][q] == null:
		printerr("Tried adding to tile %d, %d, which does not exist." % [r, q])
		return
		
	var entity := entity_type.create_entity() as Entity
	var tile = tiles[r][q] as Tile

	tile.add_entity(entity)
	return entity

## could maybe be put in Utils singleton
func tile_distance(r1: int, q1: int, r2: int, q2: int):
	return (abs(q1 - q2) 
			+ abs(q1 + r1 - q2 - r2)
			+ abs(r1 - r2)) / 2

func is_location_in_bounds(coord: Vector2i) -> bool:
	var r = coord.x
	var q = coord.y
	if r < 0 or r >= len(tiles):
		return false
	if q < 0 or q >= len(tiles[0]):
		return false
	return tiles[r][q] != null
	
func is_location_obstructed(coord: Vector2i) -> bool:
	var r = coord.x
	var q = coord.y
	var tile = tiles[r][q]
	if tile == null:
		return true
	for entity in tile.entities:
		if entity.type.is_obstacle:
			return true
	return false
	

## returns a list of Tiles forming the straight line between tile1 and tile2.
## (obstacles are ignored)
func get_line(tile1: Tile, tile2: Tile) -> Array[Tile]:
	# TODO
	return []

## this can be used for enemy movement, since it respects obstacles.
func get_shortest_path(tile1: Tile, tile2: Tile) -> Array[Tile]:
	return []

## Returns the list of tiles within `dist` distance of the tile (r_center, q_center)
func get_all_tiles_in_distance(r_center: int, q_center: int, dist: int):
	assert(dist >= 0)
	var s_center := - q_center - r_center
	var tiles_in_distance: Array[Tile] = []
	for q in range(-dist, dist + 1):
		for r in range(-dist, dist+1):
			for s in range(-dist, dist+1):
				if q + r + s == 0:  # valid coordinate
					var tile_indices: Vector3i = Utility.cube_add(q_center, r_center, s_center, q, r, s)
					var tile: Tile = tiles[tile_indices.x][tile_indices.y]
					if tile != null:
						tiles_in_distance.append(tile)

	return tiles_in_distance
	
	
func _highlight_tile_set(tiles: Array[Tile], type: Highlight.Type):
	for tile in tiles:
		tile.set_highlight(type, true)
		
func _unhighlight_tile_set(tiles: Array[Tile], type: Highlight.Type):
	for tile in tiles:
		tile.set_highlight(type, false)
		
		
func move_entity(entity: Entity, target: Tile):
	# kind of a cursed call but this is how we do it I guess
	entity.move(target)
	
	pass

func get_all_tiles() -> Array[Tile]:
	var all_tiles: Array[Tile] = []
	var num_rows = len(tiles)
	assert(num_rows > 0, "empty tiles.")
	var num_cols = len(tiles[0])
	
	for r in range(num_rows):
		for q in range(num_cols):
			var tile = tiles[r][q]
			if tile != null:
				all_tiles.append(tile)
	
	return all_tiles

func get_all_entities() -> Array[Entity]:
	var all_entities: Array[Entity] = []
	for tile in get_all_tiles():
		all_entities.append_array(tile.entities)
	return all_entities

func find_all_tiles_with(type: EntityType) -> Array[Tile]:
	var tiles_with: Array[Tile] = []
	var num_rows = len(tiles)
	assert(num_rows > 0, "empty tiles.")
	var num_cols = len(tiles[0])
	
	for r in range(num_rows):
		for q in range(num_cols):
			var tile = tiles[r][q]
			if tile != null:
				#if r == 3 and q == 3:
					#print(tile.entities[0] as Entity)
				for ent in tile.entities:
					if ent.type == type:
						tiles_with.append(tile)
						break

	return tiles_with

## Returns the first Entity found matching the given type
func find_entity(type: EntityType) -> Entity:
	for r in range(len(tiles)):
		for q in range(len(tiles[0])):
			var tile = tiles[r][q]
			if tile != null:
				for ent in tile.entities:
					if ent.type == type:
						return ent
	return null
	
func highlight_entity_type(type: EntityType):
	_highlight_tile_set(find_all_tiles_with(type), Highlight.Type.Energy)
	
func unhighlight_entity_type(type: EntityType):
	_unhighlight_tile_set(find_all_tiles_with(type), Highlight.Type.Energy)
	

func search(from: Vector2i, to: Vector2i) -> LevelSearch:
	return LevelSearch.new(self, from, to)

# ----- tool part -----
@export var create_catan_grid: bool = false:
	set(value):
		if value == true:
			init_basic_grid(3)
