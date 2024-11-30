class_name Level extends Node3D

## We're using (r,q)-axial coordinates, for a reference see
## https://www.redblobgames.com/grids/hexagons/#coordinates-axial
## 2D Array of tiles, indexed with (r,q)
var tiles: Array[Array] = []  # Tile
var n_rows: int  # r in (0, n_rows - 1)
var n_cols: int  # q in (0, n_cols - 1)

var graveyard: Array[Entity]
var combat: Combat

@onready var player: PlayerEntity
@onready var visual_effects: Node3D = $VisualEffects
@onready var visual_entities: Node3D = $VisualEntities

@onready var entities: LevelEntities = LevelEntities.new(self)

var entity_type_count := {}

const Q_BASIS: Vector2 = Vector2(sqrt(3), 0)
const R_BASIS: Vector2 = Vector2(sqrt(3)/2, 3./2)

func _ready() -> void:
	pass

func clear():
	for row in tiles:
		for tile in row:
			if tile != null:
				tile = tile as Tile
				for ent in tile.entities:
					ent.queue_free()
				tile.queue_free()

func init_tiles_array(rows, cols):
	for i in range(rows):
		tiles.append([])
		for j in range(cols):
			tiles[i].append(null)
	self.n_rows = rows
	self.n_cols = cols
	
func expand_level_boundaries():
	var new_rows = n_rows + 2
	var new_cols = n_cols + 2
	
	# Create new larger tiles array
	var new_tiles: Array[Array] = []
	for i in range(new_rows):
		new_tiles.append([])
		for j in range(new_cols):
			new_tiles[i].append(null)
	
	# Move existing tiles to new positions
	for r in range(n_rows):
		for q in range(n_cols):
			if tiles[r][q] != null:
				new_tiles[r+1][q+1] = tiles[r][q]
				tiles[r][q].r = r+1
				tiles[r][q].q = q+1
	
	# Create new tiles for expanded areas
	for r in range(new_rows):
		for q in range(new_cols):
			@warning_ignore("integer_division")
			if new_tiles[r][q] == null and Utility.rq_distance(r, q, new_rows/2, new_cols/2) <= new_rows/2:
				@warning_ignore("integer_division")
				var new_tile = Tile.create(r, q, new_rows/2, new_cols/2)
				new_tile.connect_with_combat(combat)
				add_child(new_tile.tile3d)
				new_tile.tile3d.owner = self
				new_tiles[r][q] = new_tile
	
	# Update level properties
	tiles = new_tiles
	n_rows = new_rows
	n_cols = new_cols

func shrink_level_boundaries() -> bool:
	if n_rows <= 3 or n_cols <= 3:
		#push_error("Cannot shrink further: grid too small")
		return false
	
	var new_rows = n_rows - 2
	var new_cols = n_cols - 2
	
	# Check if there are any entities on tiles to be deleted
	for r in [0, n_rows - 1]:
		for q in range(n_cols):
			if tiles[r][q] != null and not tiles[r][q].entities.is_empty():
				#push_error("Cannot shrink: entities present on border tiles")
				return false
	for r in range(1, n_rows - 1):
		for q in [0, n_cols - 1]:
			if tiles[r][q] != null and not tiles[r][q].entities.is_empty():
				#push_error("Cannot shrink: entities present on border tiles")
				return false
	
	# Create new smaller tiles array
	var new_tiles: Array[Array] = []
	for i in range(new_rows):
		new_tiles.append([])
		for j in range(new_cols):
			new_tiles[i].append(null)
	
	# Move existing tiles to new positions
	for r in range(1, n_rows - 1):
		for q in range(1, n_cols - 1):
			if tiles[r][q] != null:
				new_tiles[r-1][q-1] = tiles[r][q]
				tiles[r][q].r = r-1
				tiles[r][q].q = q-1
	
	# Remove tiles outside new boundaries
	for r in [0, n_rows - 1]:
		for q in range(n_cols):
			if tiles[r][q] != null:
				tiles[r][q].queue_free()
	for r in range(1, n_rows - 1):
		for q in [0, n_cols - 1]:
			if tiles[r][q] != null:
				tiles[r][q].queue_free()
	
	# Update level properties
	tiles = new_tiles
	n_rows = new_rows
	n_cols = new_cols
	return true
	
func get_grid_size() -> int:
	assert(n_rows == n_cols, "Grid size is only defined for n_rows == n_cols (basic grid)")
	@warning_ignore("integer_division")
	return (n_rows - 1) / 2

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
			new_tile.connect_with_combat(combat)
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
	
	if (not is_location_in_bounds(location)) or tiles[r] == null or tiles[r][q] == null:
		push_error("Tried getting tile %d, %d, which does not exist." % [r, q])
		return null

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
	if location.x >= 0 and location.y >= 0:
		if location.x < len(tiles):
			if location.y < len(tiles[location.x]):
				return tiles[location.x][location.y]
	return null

## returns a list of Tiles forming the straight line between tile1 and tile2.
## Only tile2 is included
## (obstacles are ignored)
const EDGE_DELTA = .01
func get_line(tile1: Tile, tile2: Tile, include_edge_tiles := true) -> Array[Tile]:
	var line : Array[Tile] = []
	if not (tile1 and tile2):
		return line
	var dist := tile1.distance_to(tile2)
	var pos1 = Vector2(tile1.location)
	var pos2 = Vector2(tile2.location)
	for i in range(1,dist+1):
		var lerp_pos = lerp(pos1, pos2, float(i)/dist)
		line.append_array(get_tiles_from_float_vec(lerp_pos, not include_edge_tiles))
	
	return line

func get_tiles_from_float_vec(vec: Vector2, just_one := false) -> Array[Tile]:
	var _tiles : Array[Tile] = []
	if just_one:
		_tiles.append(get_tile_by_location(Vector2i(round(vec))))
		return _tiles
	if abs(vec.x - int(vec.x) - .5) < EDGE_DELTA and abs(vec.y - int(vec.y) - .5) < EDGE_DELTA:
		_tiles.append_array(get_tiles_from_float_vec(vec + Vector2(.5, -.5), true))
		_tiles.append_array(get_tiles_from_float_vec(vec + Vector2(-.5, .5), true))
	elif abs(vec.x - int(vec.x) - .5) < EDGE_DELTA:
		_tiles.append_array(get_tiles_from_float_vec(vec + Vector2(.5, 0.0), true)) 
		_tiles.append_array(get_tiles_from_float_vec(vec + Vector2(-.5, 0.0), true))
	elif abs(vec.y - int(vec.y) - .5) < EDGE_DELTA:
		_tiles.append_array(get_tiles_from_float_vec(vec + Vector2(0.0, .5), true)) 
		_tiles.append_array(get_tiles_from_float_vec(vec + Vector2(0.0, -.5), true))
	else:
		_tiles.append(get_tile_by_location(Vector2i(round(vec))))
	return _tiles

## this can be used for enemy movement, since it respects obstacles.
## source tile is not included
func get_shortest_path(tile1: Tile, tile2: Tile, mask: int = Constants.INT64_MAX) -> Array[Tile]:
	var search_object := search(tile1.location, tile2.location, mask)
	search_object.execute()
	var location_path := search_object.path
	var path: Array[Tile] = []
	path.append_array(location_path.map(func(location): return get_tile_by_location(location)))
	return path
	
func get_shortest_distance(tile1: Tile, tile2: Tile, mask: int = Constants.INT64_MAX):
	var path = get_shortest_path(tile1, tile2, mask)
	assert(path != null, "path == null in get_shortest_distance")
	if path.is_empty():
		return -1
	return len(path)

func get_all_tiles_in_distance_of_tile(tile: Tile, dist: int) -> Array[Tile]:
	return get_all_tiles_in_distance(tile.r, tile.q, dist)

func get_all_tiles_with_min_distance_of_tile(tile: Tile, dist: int) -> Array[Tile]:
	if dist <= 0:
		return get_all_tiles()
	var exclude := get_all_tiles_in_distance_of_tile(tile, dist - 1)
	return get_all_tiles().filter(func (t): return t not in exclude)

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

func get_cone_tiles(origin: Tile, destination: Tile, range_start : int, range_end : int, \
				distance : int, exclude_origin := false) -> Array[Tile]:
	var _tiles: Array[Tile] = []
	if origin == destination:
		return _tiles
	var direction : Vector2i = origin.direction_to(destination)
	var cone_origin : Tile = origin.step_in_direction(direction * distance)
	if cone_origin:
		_tiles.append(cone_origin)
		var direction_left : Vector2i = Tile.rotate_direction_clockwise(direction,-1)
		var direction_right : Vector2i = Tile.rotate_direction_clockwise(direction,1)
		for i in range(range_start, range_end):
			if i == 0:
				continue
			var left_edge := cone_origin.step_in_direction(direction_left * i)
			var middle_edge := cone_origin.step_in_direction(direction * i)
			var right_edge := cone_origin.step_in_direction(direction_right * i)
			_tiles.append(left_edge)
			_tiles.append_array(get_line(left_edge, middle_edge))
			_tiles.append_array(get_line(middle_edge, right_edge))
	if exclude_origin:
		_tiles.erase(origin)
	return _tiles

func get_drainable_entities() -> Dictionary: # Tile -> Array[Entity]
	var tile_to_ents: Dictionary = {}
	for tile in get_all_tiles():
		if tile.is_drainable():
			tile_to_ents[tile] = tile.get_drainable_entities()
	return tile_to_ents


func _highlight_tile_set(highlight_tiles: Array[Tile], type: Highlight.Type):
	for tile in highlight_tiles:
		if tile:
			tile.set_highlight(type, true)
		
func _unhighlight_tile_set(highlight_tiles: Array[Tile], type: Highlight.Type):
	for tile in highlight_tiles:
		tile.set_highlight(type, false)
		
#func highlight_movement_range(entity: Entity, movement_range: int) -> Array[Tile]:
	#var highlight_tiles = get_all_tiles_in_distance(entity.current_tile.r,
													#entity.current_tile.q, movement_range)
	#var distance_filtered: Array[Tile] = []
	#for tile in highlight_tiles:
		#var path = get_shortest_path(entity.current_tile, tile)
		#var distance = len(path)
		#if distance <= movement_range:
			#distance_filtered.append(tile)
			#
	## filter obstacles
	#distance_filtered = distance_filtered.filter(func(t): return not t.is_blocked())
	#
	#_highlight_tile_set(distance_filtered, Highlight.Type.MovementTarget)
	#return distance_filtered
		
		
func move_entity(entity: Entity, target: Tile):
	entity.move(target)

func move_entity_to_graveyard(entity: Entity):
	if entity.current_tile:
		entity.entering_graveyard.emit()
		entity.current_tile.remove_entity(entity)
		entity.entered_graveyard.emit()
		graveyard.append(entity)
	else:
		push_error("Entity has not tile (Maybe its already in the graveyard)")

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
	var ents: Array[Entity] = []
	for t in get_all_tiles():
		ents.append_array(t.entities)
	return ents

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



func search(from: Vector2i, to: Vector2i, mask: int = Constants.INT64_MAX) -> LevelSearch:
	return LevelSearch.new(self, from, to, mask)

# ----- tool part -----
@export var create_catan_grid: bool = false:
	set(value):
		if value == true:
			init_basic_grid(3)

func save_without_combat(path: String):
	Combat.serialize_level_as_combat_state(self).save_to_disk(path)

var _im_arr: ImmediateArrows
func immediate_arrows() -> ImmediateArrows:
	if not _im_arr:
		_im_arr = VFX.IMMEDIATE_ARROWS.instantiate()
		add_child(_im_arr)
	return _im_arr

## This saves the hover order if the last X Tiles that were hovered.
## We use it to make inputing the movement clean.
var _hover_memory: Array[Tile] = []
const HOVER_MEMORY_SIZE = 4
## This is used in PAHoverTile to keep track of the last hovers.
func append_to_hover_memory(t: Tile) -> void:
	_hover_memory.push_back(t)
	if _hover_memory.size() > HOVER_MEMORY_SIZE:
		_hover_memory.pop_front()

## Returns the shortest path between two tile while favoring tiles that were recently hovered.
func get_shortest_path_with_memory(tile1: Tile, tile2: Tile, mask: int = Constants.INT64_MAX) -> Array[Tile]:
	return _process_shortest_path_with_memory(tile1, [tile2], _hover_memory.duplicate(), [], mask)

func _process_shortest_path_with_memory(origin: Tile, targets: Array[Tile], \
	memory: Array[Tile], path: Array[Tile], mask: int = Constants.INT64_MAX) -> Array[Tile]:
		targets = targets as Array[Tile]
		memory = memory as Array[Tile]
		path = path as Array[Tile]
		var origin_array: Array[Tile] = [origin]
		# Get first path calculated
		if path.is_empty():
			path = _get_chained_path(origin_array + targets, mask)
		# Return if we processed all of memory
		if memory.is_empty():
			return path
		# Process next memory tile
		var memory_tile: Tile = memory.pop_back()
		# Add to targets if it's already in the path
		if memory_tile in path:
			if memory_tile not in targets:
				targets.push_front(memory_tile)
		# Only when it is not a target already
		if memory_tile not in targets:
			# Calculate the new version
			var memory_tile_array: Array[Tile] = [memory_tile]
			var new_path = _get_chained_path(origin_array + memory_tile_array + targets, mask)
			# If new version isn't bigger, change the path and add memory tile
			if new_path.size() == path.size():
				path = new_path
				targets.push_front(memory_tile)
		return _process_shortest_path_with_memory(origin, targets, memory, path, mask)

func _get_chained_path(journey: Array[Tile], mask: int = Constants.INT64_MAX) -> Array[Tile]:
	var path: Array[Tile] = []
	for i in range(journey.size() - 1):
		var step := get_shortest_path(journey[i], journey[i+1], mask)
		if step.is_empty():
			return []
		path.append_array(step)
	return path
