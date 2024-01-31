class_name LevelSearch extends Object

var level: Level
var start: Vector2i
var target: Vector2i
var mask: int

var open_set: Array[TileGridSearchEntry]
var closed_set: Dictionary = {}

var path_found: bool = false
var path: Array[Vector2i]

func _init(_level: Level, _start: Vector2i, _target: Vector2i, _mask: int):
	level = _level
	start = _start
	target = _target
	mask = _mask
	
func execute(max_iterations = 1000):
	_append_observed_tile(start, -1.0, null)
	var iterations = 0
	while len(open_set) > 0 and not _process_tile():
		iterations += 1
		if iterations > max_iterations:
			return

func _observe_tile(coord: Vector2i, current_path_distance: float, parent: TileGridSearchEntry):
	if not level.is_location_in_bounds(coord):
		return
	if closed_set.has(coord):
		return
	if level.is_location_obstructed(coord, mask):
		return
	_append_observed_tile(coord, current_path_distance, parent)

func _append_observed_tile(coord: Vector2i, current_path_distance: float, parent: TileGridSearchEntry):
	var distance_to_target = (coord - target).length()
	var new_distance_from_start = current_path_distance + 1.0
	open_set.append(TileGridSearchEntry.new(parent, coord, new_distance_from_start, distance_to_target))
	closed_set[coord] = true

func _process_tile() -> bool:
	var next = _pop_next_lowest()
	print(str(next.coord))
	if next.coord == target:
		_backtrack_path(next)
		return true
	
	for grid_direction in TileGridHelper.all_directions:
		var to_observe_tile_coord = next.coord + TileGridHelper.get_direction_offset(grid_direction)
		_observe_tile(to_observe_tile_coord, next.f_score, next)
	
	return false
	
func _pop_next_lowest() -> TileGridSearchEntry:
	var min_score: float = INF
	var best: TileGridSearchEntry
	var best_position = -1
	for pos in range(len(open_set)):
		var entry = open_set[pos]
		var score = entry.f_score + entry.g_score
		if score < min_score:
			min_score = score
			best = entry
			best_position = pos
	if best_position != -1:
		open_set.remove_at(best_position)
	return best
	
func _backtrack_path(target_entry: TileGridSearchEntry):
	var current = target_entry
	var temp_path: Array[Vector2i] = []
	while current.parent != null:
		temp_path.append(current.coord)
		current = current.parent
	temp_path.reverse()
	path = temp_path
	path_found = true

class TileGridSearchEntry extends Object:
	var parent: TileGridSearchEntry
	var coord: Vector2i
	var g_score: float
	var f_score: float
	
	func _init(_parent: TileGridSearchEntry, _coord: Vector2i, _g_score: float, _f_score: float):
		parent = _parent
		coord = _coord
		g_score = _g_score
		f_score = _f_score

