@tool
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

var graveyard: Array[Entity]
var combat: Combat

@onready var player: PlayerEntity

@onready var visual_effects: Node3D = $VisualEffects
@onready var visual_entities: Node3D = $VisualEntities

var entity_type_count := {}

var TileScene = preload("res://Logic/Tiles/Tile.tscn")
const Q_BASIS: Vector2 = Vector2(sqrt(3), 0)
const R_BASIS: Vector2 = Vector2(sqrt(3)/2, 3./2)

func clear():
	for row in tiles:
		for tile in row:
			if tile != null:
				tile.queue_free()

func init_tiles_array(rows, cols):
	for i in range(rows):
		tiles.append([])
		for j in range(cols):
			tiles[i].append(null)
	self.n_rows = rows
	self.n_cols = cols

func init_basic_grid(n: int):
	# The origin tile will have coordinates (r=n, q=n).
	# This makes it so the top-left tile will have coordinates 0,0 in the tiles 2D array
	# The origin tile will be centered at the position of the Level node.
	# initiate 2d Array, it will have dimensions (2n+1, 2n+1)
	init_tiles_array(2*n+1, 2*n+1)

	for r in range(0, 2*n + 1):
		for q in range(0, 2*n + 1):
			# first off, check if this tile would have distance > n from origin
			# in that case continue and put null into the array position
			if Utility.rq_distance(r, q, n, n) > n: 
				continue

			var new_tile = Tile.create(r, q, n, n)
			add_child(new_tile)
			new_tile.owner = self
			tiles[r][q] = new_tile
	
## Serialize the whole tile grid and all entities.
func serialize() -> LevelState:
	var level_state = LevelState.new()
	level_state.rows = n_rows
	level_state.columns = n_cols
	
	var tile_data: Array[TileState] = []
	var tile: Tile
	for r in range(0, n_rows):
		for q in range(0, n_cols):
			tile = tiles[r][q]
			if tile != null:
				tile_data.append(tile.serialize())
	level_state.tiles = tile_data
	
	level_state.graveyard.append_array(graveyard.map(func (x): return x.serialize()))
	
	return level_state

func add_type_count(type: EntityType) -> int:
	if not type in entity_type_count:
		entity_type_count[type] = 0
	entity_type_count[type] += 1
	return entity_type_count[type]

func get_tile(location: Vector2i) -> Tile:
	var r = location.x
	var q = location.y
	
	if tiles[r][q] == null:
		printerr("Tried getting tile %d, %d, which does not exist." % [r, q])
	return tiles[r][q] as Tile

## go through visual instances of this tile and assert that they are visible and
## at the right position. Later, we can also call some kind of "update" here
## for the UI (think healthbar, etc)
func update_visual_entities(tile: Tile):
	var r_tile := tile.r
	var vis_ent: VisualEntity
	for ent in tile.entities:
		if is_instance_valid(ent.visual_entity):
			vis_ent = ent.visual_entity
			if not vis_ent in $VisualEntities.get_children():
				$VisualEntities.add_child(vis_ent)
			vis_ent.position = tile.position

func is_location_in_bounds(coord: Vector2i) -> bool:
	var r = coord.x
	var q = coord.y
	if r < 0 or r >= len(tiles):
		return false
	if q < 0 or q >= len(tiles[0]):
		return false
	return tiles[r][q] != null
	
func is_location_obstructed(coord: Vector2i, mask: int) -> bool:
	var r = coord.x
	var q = coord.y
	var tile : Tile = tiles[r][q]
	if tile == null:
		return true
	return tile.is_obstacle(mask)
	

func get_tile_by_location(location: Vector2i) -> Tile:
	return tiles[location.x][location.y]

## returns a list of Tiles forming the straight line between tile1 and tile2.
## (obstacles are ignored)
func get_line(tile1: Tile, tile2: Tile) -> Array[Tile]:
	var line : Array[Tile] = []
	var dist := tile1.distance_to(tile2)
	var pos1 = Vector2(tile1.location)
	var pos2 = Vector2(tile2.location)
	for i in range(dist+1):
		line.append(get_tile_by_location(Vector2i(round(lerp(pos1, pos2, float(i)/dist)))))
	
	return line

## this can be used for enemy movement, since it respects obstacles.
func get_shortest_path(tile1: Tile, tile2: Tile, mask: int = Constants.INT64_MAX) -> Array[Tile]:
	var search_object := search(tile1.location, tile2.location, mask)
	search_object.execute()
	var location_path := search_object.path
	var path: Array[Tile] = []
	path.append_array(location_path.map(func(location): return get_tile_by_location(location)))
	return path

func get_all_tiles_in_distance_of_tile(tile: Tile, dist: int) -> Array[Tile]:
	return get_all_tiles_in_distance(tile.r, tile.q, dist)

## Returns the list of tiles within `dist` distance of the tile (r_center, q_center)
func get_all_tiles_in_distance(r_center: int, q_center: int, dist: int) -> Array[Tile]:
	assert(dist >= 0)
	var s_center := - q_center - r_center
	var tiles_in_distance: Array[Tile] = []
	for q in range(-dist, dist+1):
		for r in range(-dist, dist+1):
			for s in range(-dist, dist+1):
				if q + r + s == 0:  # valid coordinate
					var tile_indices: Vector3i = Utility.cube_add(r_center, q_center, s_center, q, r, s)
					if not is_location_in_bounds(Vector2i(tile_indices.x, tile_indices.y)):
						continue
					var tile: Tile = tiles[tile_indices.x][tile_indices.y]
					if tile != null:
						tiles_in_distance.append(tile)

	return tiles_in_distance


func get_center_tile() -> Tile:
	@warning_ignore("integer_division")
	var r_center: int = n_rows / 2
	@warning_ignore("integer_division")
	var q_center: int = n_cols / 2
	
	return tiles[r_center][q_center]


func _highlight_tile_set(highlight_tiles: Array[Tile], type: Highlight.Type):
	for tile in highlight_tiles:
		tile.set_highlight(type, true)
		
func _unhighlight_tile_set(highlight_tiles: Array[Tile], type: Highlight.Type):
	for tile in highlight_tiles:
		tile.set_highlight(type, false)
		
func highlight_movement_range(entity: Entity, movement_range: int) -> Array[Tile]:
	var highlight_tiles = get_all_tiles_in_distance(entity.current_tile.r,
													entity.current_tile.q, movement_range)
	_highlight_tile_set(highlight_tiles, Highlight.Type.Movement)
	return highlight_tiles
		
		
func move_entity(entity: Entity, target: Tile):
	entity.move(target)

func move_entity_to_graveyard(entity: Entity):
	if entity.current_tile:
		entity.current_tile.remove_entity(entity)
		graveyard.append(entity)
	else:
		printerr("Entity has not tile (Maybe its already in the graveyard)")

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
func find_entity_type(type: EntityType) -> Entity:
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

func entities() -> LevelEntities:
	return LevelEntities.new(self)

func search(from: Vector2i, to: Vector2i, mask: int = Constants.INT64_MAX) -> LevelSearch:
	return LevelSearch.new(self, from, to, mask)

# ----- tool part -----
@export var create_catan_grid: bool = false:
	set(value):
		if value == true:
			init_basic_grid(3)

func save_without_combat(path: String):
	Combat.serialize_level_as_combat_state(self).save_to_disk(path)

static func load_without_combat(path: String):
	return Combat.deserialize_level_from_combat_state(CombatState.load_from_disk(path))

