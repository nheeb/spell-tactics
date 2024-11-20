class_name GameMain extends Control


func _ready() -> void:
	ActivityManager.push(RootActivity.new())
	if Game.DEBUG_SPELL_TESTING:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(CombatActivity.new("res://Content/Levels/SpellTesting/spell_test.tres"))
		await get_tree().process_frame
		add_test_border()
	elif Game.DEBUG_SKIP_OVERWORLD:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(CombatActivity.new("res://Content/Levels/clearing.tres"))
	elif Game.DEBUG_SKIP_POST_COMBAT:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(CombatActivity.new("res://Content/Levels/clearing.tres"))
		ActivityManager.substitute(PostCombatActivity.new())
	elif Game.DEBUG_DECK_VIEW:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(BrowseDeckActivity.new())
	elif Game.DEBUG_DECK_PURGE:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(PurgeDeckActivity.new(20, false))


# todo: move elsewhere
func add_test_border():
	test()

	var parent = get_tree().root.get_node('Main/ActivityRouter/MainScene/Viewport3D/World/Level')
	var selected_tiles: Array[Vector2i] = [
		Vector2i(5,5),
		Vector2i(7,5),
		Vector2i(6,4),
		Vector2i(5,7),
		Vector2i(7,4),
	]
	var chunks = continuous_chunks(selected_tiles)
	for c in chunks:
		var chunk: Array[Vector2i]
		chunk.assign(c)
		var borders = remove_shared_borders(chunk)
		var coords = create_mesh(borders)
		var mesh = render_mesh(coords, 0.3)
		parent.add_child(mesh)
	# parent.add_child(render_mesh([Vector2(5.5, 5), Vector2(7, 5)], 0.3))


func xy(v: Vector3i) -> Vector2:
	return Vector2(v.x, v.y)

func tile_coord_to_screen_coord(tile: Vector2, height: float):
	var r_tile = tile.x
	var q_tile = tile.y
	var level = Game.world.level
	var r_center = level.n_rows/2 + level.n_rows % 1
	var q_center = level.n_cols/2 + level.n_cols % 1
	var xz_translation: Vector2 = (r_tile-r_center) * level.Q_BASIS + (q_tile-q_center) * level.R_BASIS 
	return Vector3(xz_translation.x, height, xz_translation.y)

func get_border_offset(border: int) -> Array[Vector2]:
	const h = 0.5
	const q = 0.25
	if border == BORDER_WEST:
		return [Vector2(-h, -q), Vector2(-h, q)]
	if border == BORDER_NW:
		return [Vector2(-h, -q), Vector2(0, -h)]
	if border == BORDER_NE:
		return [Vector2(0, -h), Vector2(h, -q)]
	if border == BORDER_EAST:
		return [Vector2(h, -q), Vector2(h, q)]
	if border == BORDER_SE:
		return [Vector2(h, q), Vector2(0, h)]
	if border == BORDER_SW:
		return [Vector2(0, h), Vector2(-h, q)]
	push_error("Invalid border")
	return [Vector2(-q, 0), Vector2(q, 0)]

const HEIGHT_LOW = 0
func render_mesh(points: Array[Vector2], height: float):
	assert(len(points) >= 2)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var i = 0
	while i < len(points) - 1:
		st.add_triangle_fan(PackedVector3Array([
			tile_coord_to_screen_coord(points[i], HEIGHT_LOW),
			tile_coord_to_screen_coord(points[i], HEIGHT_LOW+height),
			tile_coord_to_screen_coord(points[i+1], HEIGHT_LOW+height),
			tile_coord_to_screen_coord(points[i+1], HEIGHT_LOW),
		]), PackedVector2Array([
			Vector2(0, 0),
			Vector2(0, 1),
			Vector2(1, 1),
			Vector2(1, 0),
		]))
		# todo: switch to +1 (i.e. sort+remove duplicate coords)
		i += 2

	var mesh = MeshInstance3D.new()
	var material = preload("res://VFX/Materials/DebugPink.tres")
	mesh.set_mesh(st.commit())
	mesh.material_override = material
	mesh.name = "TEST_BORDER"
	return mesh

func create_mesh(tiles: Array[Vector3i]) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for tile in tiles:
		var i = 1
		while i < BORDER_ALL:
			if tile.z & i > 0:
				var o = get_border_offset(i)
				out.append(xy(tile) + o[0])
				out.append(xy(tile) + o[1])
			i = i << 1
	return out

const BORDER_WEST = 1
const BORDER_NW = 2
const BORDER_NE = 4
const BORDER_EAST = 8
const BORDER_SE = 16
const BORDER_SW = 32
const BORDER_ALL = 0b111111
func remove_shared_borders(tiles: Array[Vector2i]) -> Array[Vector3i]:
	var selection = {}
	for tile in tiles:
		selection[tile] = BORDER_ALL

	for tile in selection.keys():
		var border = selection[tile]
		if selection.has(Vector2i(tile.x - 1, tile.y)):
			border -= BORDER_WEST
		if selection.has(Vector2i(tile.x, tile.y - 1)):
			border -= BORDER_NW
		if selection.has(Vector2i(tile.x + 1, tile.y - 1)):
			border -= BORDER_NE
		if selection.has(Vector2i(tile.x + 1, tile.y)):
			border -= BORDER_EAST
		if selection.has(Vector2i(tile.x, tile.y + 1)):
			border -= BORDER_SE
		if selection.has(Vector2i(tile.x - 1, tile.y + 1)):
			border -= BORDER_SW
		selection[tile] = border

	var output: Array[Vector3i] = []
	for tile in selection.keys():
		output.append(Vector3i(tile.x, tile.y, selection[tile]))
	return output

func continuous_chunks(tiles: Array[Vector2i]) -> Array:
	var chunks = []
	var current_chunk = []
	while len(tiles) > 0:
		current_chunk.append(tiles.pop_back())
		for i in range(len(tiles)-1, -1, -1):
			for tile in current_chunk:
				if is_neighbour(tile, tiles[i]):
					current_chunk.append(tiles.pop_at(i))
					break
		chunks.append(current_chunk)
		current_chunk = []
	return chunks

func is_neighbour(a:Vector2i, b: Vector2i) -> bool:
	return (
	# horizontal
		(a.y == b.y and abs(a.x - b.x) <= 1)
	# vertical
		or (a.x == b.x and abs(a.y - b.y) <= 1)
	# diagonal
		or (abs(a.x - b.x) == 1 and abs(b.y - a.y) == 1 and sign(a.x - b.x) != sign(a.y - b.y))
	)

func array_eq(a: Array, b: Array):
	if len(a) != len(b):
		return false
	for i in range(len(a)):
		if a[i] != b[i]:
			return false
	return true

func test():
	assert(is_neighbour(Vector2i(6, 5), Vector2i(6, 5)) == true)
	assert(is_neighbour(Vector2i(6, 5), Vector2i(5, 5)) == true)
	assert(is_neighbour(Vector2i(6, 5), Vector2i(6, 4)) == true)
	assert(is_neighbour(Vector2i(6, 5), Vector2i(7, 4)) == true)
	assert(is_neighbour(Vector2i(6, 5), Vector2i(7, 5)) == true)
	assert(is_neighbour(Vector2i(6, 5), Vector2i(6, 6)) == true)
	assert(is_neighbour(Vector2i(6, 5), Vector2i(5, 6)) == true)

	assert(is_neighbour(Vector2i(6, 5), Vector2i(1, 1)) == false)
	assert(is_neighbour(Vector2i(6, 5), Vector2i(8, 5)) == false)
	assert(is_neighbour(Vector2i(6, 5), Vector2i(5, 4)) == false)
	assert(is_neighbour(Vector2i(6, 5), Vector2i(7, 6)) == false)
	assert(is_neighbour(Vector2i(6, 5), Vector2i(8, 5)) == false)
	
	assert(array_eq(continuous_chunks([]), []))
	assert(array_eq(continuous_chunks([Vector2i(1, 1)]), [[Vector2i(1, 1)]]))
	assert(array_eq(continuous_chunks([Vector2i(1, 1), Vector2i(5, 5)]), [[Vector2i(5, 5)], [Vector2i(1, 1)]]))
	assert(array_eq(continuous_chunks([Vector2i(6, 5), Vector2i(5, 5)]), [[Vector2i(5, 5), Vector2i(6, 5)]]))
	assert(array_eq(continuous_chunks([Vector2i(1, 1), Vector2i(6, 5), Vector2i(5, 5)]), [[Vector2i(5, 5), Vector2i(6, 5)], [Vector2i(1, 1)]]))
	
	assert(array_eq(remove_shared_borders([]), []))
	assert(array_eq(remove_shared_borders([Vector2i(6, 5)]), [Vector3i(6, 5, BORDER_ALL)]))
	assert(array_eq(remove_shared_borders([Vector2i(6, 5), Vector2i(7, 5)]), [
		Vector3i(6, 5, BORDER_ALL - BORDER_EAST),
		Vector3i(7, 5, BORDER_ALL - BORDER_WEST),
	]))
	assert(array_eq(remove_shared_borders([Vector2i(6, 5), Vector2i(6, 4)]), [
		Vector3i(6, 5, BORDER_ALL - BORDER_NW),
		Vector3i(6, 4, BORDER_ALL - BORDER_SE),
	]))
	assert(array_eq(remove_shared_borders([Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4)]), [
		Vector3i(6, 5, BORDER_ALL - BORDER_NW - BORDER_NE),
		Vector3i(6, 4, BORDER_ALL - BORDER_SE - BORDER_EAST),
		Vector3i(7, 4, BORDER_ALL - BORDER_SW - BORDER_WEST),
	]))
