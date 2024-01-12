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

func _ready() -> void:
	init_basic_grid(3)
	
class Index:
	var r: int
	var q: int
	
	func _init(r: int, q: int):
		self.r = r
		self.q = q
	
var TileScene = preload("res://Logic/Tiles/Tile.tscn")
const Q_BASIS: Vector2 = Vector2(sqrt(3), 0)
const R_BASIS: Vector2 = Vector2(sqrt(3)/2, 3./2)
const ROCK_TEST_ENTITY := preload("res://Entities/Types/Rock.tres")
const WATER_TEST_ENTITY := preload("res://Entities/Types/Water.tres")
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
			# place all tiles in pointy-up fashion
			# that mean they are higher than they are wide
			var new_tile: Tile = TileScene.instantiate()
			add_child(new_tile)
			new_tile.owner = self
			var xz_translation: Vector2 = (r-n) * Q_BASIS + (q-n) * R_BASIS 
			new_tile.position = Vector3(xz_translation.x, 0.0, xz_translation.y)
			new_tile.get_node("DebugLabel").text = "(%s, %s)" % [r, q]
			tiles[r][q] = new_tile
	
	# let's add a rock to the center tile
	add_entity(3, 3, ROCK_TEST_ENTITY)
	add_entity(3, 4, WATER_TEST_ENTITY)

func add_entity(r: int, q: int, entity_type: EntityType):
	# should entities only be part of tiles or do we want a second data structure outside?
	# here, in TileGrid
	if tiles[r][q] == null:
		printerr("Tried adding to tile %d, %d, which does not exist." % [r, q])
		return
	(tiles[r][q] as Tile).add_entity(entity_type.to_entity())

func rq_to_tile(r: int, q: int) -> Tile:
	return tiles[r][q].add_tile()

## can return null if the tile is not present
func tile_to_rq(t: Tile) -> Vector2i:
	# TODO !!
	return Vector2i(0, 0)
			

## could maybe be put in Utils singleton
func tile_distance(r1: int, q1: int, r2: int, q2: int):
	return (abs(q1 - q2) 
			+ abs(q1 + r1 - q2 - r2)
			+ abs(r1 - r2)) / 2


func get_tiles_with(tile_object: Entity):
	# TODO
	pass

## returns a list of Tiles forming the straight line between tile1 and tile2.
func get_line(tile1: Tile, tile2: Tile) -> Array[Tile]:
	# TODO
	return []

## this can be used for enemy movement, since it respects obstacles.
func get_shortest_path(tile1: Tile, tile2: Tile) -> Array[Tile]:
	return []
	
func get_all_tiles_in_distance():
	# TODO obstacles
	pass
	

func move_all_entities(from: Tile, to: Tile):
	pass


# ----- tool part -----
@export var create_catan_grid: bool = false:
	set(value):
		if value == true:
			init_basic_grid(3)
