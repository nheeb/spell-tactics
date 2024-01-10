class_name TileGrid extends Node3D

## Different initialization functions should be implemented.
## For example initializing regular n-grid.
## Or loading a resource defining a map.
## Ideally, this would even work in a tool script so in-editor as well

## We're using (q,r)-axial coordinates, for a reference see
## https://www.redblobgames.com/grids/hexagons/#coordinates-axial


## 2D Array of tiles, indexed with (r,q), think row, qolumn hehe :)
var tiles: Array[Array] = []
var tile_size := 1.0


func _ready() -> void:
	init_basic_grid(3)
	

var TileScene = preload("res://Prototype/Tile.tscn")
const Q_BASIS: Vector2 = Vector2(sqrt(3), 0)
const R_BASIS: Vector2 = Vector2(sqrt(3)/2, 3./2)
func init_basic_grid(n: int):
	# The origin tile will have coordinates (r=n, q=n).
	# This makes it so the top-left tile will have coordinates 0,0 in the tiles 2D array
	# The origin tile will be centered at the position of the TileGrid node.

	# initiate 2d Array, it will have dimensions (2n, 2n)
	for _i in range(2*n + 1):
		tiles.append([])

	for r in range(0, 2*n + 1):
		for q in range(0, 2*n + 1):
			# first off, check if this tile would have distance > n from origin
			# in that case continue and put null into the array position
			if false:  # TODO dist > n
				tiles[r][q] = null 
				continue
			# place all tiles in pointy-up fashion
			# that mean they are higher than they are wide
			var new_tile: Tile = TileScene.instantiate()
			add_child(new_tile)
			var xz_translation: Vector2 = r * tile_size * Q_BASIS + q * tile_size * R_BASIS 
			new_tile.position = Vector3(xz_translation.x, 0.0, xz_translation.y)
			new_tile.get_node("DebugLabel").text = "(%s, %s)" % [r, q]
