#@tool
class_name TileGrid extends Node3D

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
	init_basic_grid(3)
	

var TileScene = preload("res://Logic/Tiles/Tile.tscn")
const Q_BASIS: Vector2 = Vector2(sqrt(3), 0)
const R_BASIS: Vector2 = Vector2(sqrt(3)/2, 3./2)
const ROCK_ENTITY := preload("res://Entities/Environment/Rock.tres")
const WATER_ENTITY := preload("res://Entities/Environment/Water.tres")
const PLAYER_ENTITY := preload("res://Entities/PlayerResource.tres")
func init_basic_grid(n: int):
	# The origin tile will have coordinates (r=n, q=n).
	# This makes it so the top-left tile will have coordinates 0,0 in the tiles 2D array
	# The origin tile will be centered at the position of the TileGrid node.
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

func add_entity(r: int, q: int, entity_type: EntityType):
	# should entities only be part of tiles or do we want a second data structure outside?
	# here, in TileGrid
	if tiles[r][q] == null:
		printerr("Tried adding to tile %d, %d, which does not exist." % [r, q])
		return
	(tiles[r][q] as Tile).add_entity(entity_type.to_entity())

## could maybe be put in Utils singleton
func tile_distance(r1: int, q1: int, r2: int, q2: int):
	return (abs(q1 - q2) 
			+ abs(q1 + r1 - q2 - r2)
			+ abs(r1 - r2)) / 2


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
	

func move_all_entities(from: Tile, to: Tile):
	pass
	
	
func _highlight_tile_set(tiles: Array[Tile], type: Highlight.Type):
	for tile in tiles:
		tile.set_highlight(type, true)
		
func _unhighlight_tile_set(tiles: Array[Tile], type: Highlight.Type):
	for tile in tiles:
		tile.set_highlight(type, false)


func get_all_tiles_with(type: EntityType) -> Array[Tile]:
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
	
func highlight_entity_type(type: EntityType):
	_highlight_tile_set(get_all_tiles_with(type), Highlight.Type.Energy)
	
func unhighlight_entity_type(type: EntityType):
	_unhighlight_tile_set(get_all_tiles_with(type), Highlight.Type.Energy)


# ----- tool part -----
@export var create_catan_grid: bool = false:
	set(value):
		if value == true:
			init_basic_grid(3)
