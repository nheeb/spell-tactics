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
	var parent = get_tree().root.get_node('Main/ActivityRouter/MainScene/Viewport3D/World/Level')
	selection_mesh(parent, [
		Vector2i(5,5),
		Vector2i(7,5),
		Vector2i(6,4),
		Vector2i(7,3),
		Vector2i(5,7),
		Vector2i(7,4),
	])

func selection_mesh(parent: Node3D, selected_tiles: Array[Vector2i]) -> Array[MeshInstance3D]:
	var chunks = continuous_chunks(selected_tiles)
	var result: Array[MeshInstance3D] = []
	for c in chunks:
		var chunk: Array[Vector2i]
		chunk.assign(c)
		var borders = remove_shared_borders(chunk)
		var coords = create_mesh(borders)
		# todo: merge all chunks into a single mesh?
		var mesh = render_mesh(coords, 0.3)
		parent.add_child(mesh)
		result.append(mesh)
	return result

func tile_coord_to_screen_coord(tile: Vector2, height: float):
	var r_tile = tile.x
	var q_tile = tile.y
	var level = Game.world.level
	var r_center = level.n_rows/2 + level.n_rows % 1
	var q_center = level.n_cols/2 + level.n_cols % 1
	var xz_translation: Vector2 = (r_tile-r_center) * level.Q_BASIS + (q_tile-q_center) * level.R_BASIS 
	return Vector3(xz_translation.x, height, xz_translation.y)

func get_border_offset(border: int) -> Vector3:
	var out = Vector3(-1,0, 0).rotated(Vector3.UP, deg_to_rad(-(border & 1) * 60 + 30))
	border >>= 1
	while border > 1:
		out = out.rotated(Vector3.UP, deg_to_rad(-60))
		border >>= 1
	return out

func apply_offset(point: Vector3, height: float):
	return tile_coord_to_screen_coord(Vector2(point.x, point.y), height) + get_border_offset(int(point.z))

const HEIGHT_LOW = 0
func render_mesh(points: Array[Vector3], height: float) -> MeshInstance3D:
	assert(len(points) >= 2)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var i = 0
	while i < len(points) - 1:
		print([
			apply_offset(points[i], HEIGHT_LOW),
			apply_offset(points[i], HEIGHT_LOW+height),
			apply_offset(points[i+1], HEIGHT_LOW+height),
			apply_offset(points[i+1], HEIGHT_LOW),
		])
		st.add_triangle_fan(PackedVector3Array([
			apply_offset(points[i], HEIGHT_LOW),
			apply_offset(points[i], HEIGHT_LOW+height),
			apply_offset(points[i+1], HEIGHT_LOW+height),
			apply_offset(points[i+1], HEIGHT_LOW),
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
	mesh.name = "SHADER_BORDER"
	return mesh

func create_mesh(tiles: Array[Vector3i]) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for tile in tiles:
		var i = 1
		while i < BORDER_ALL:
			if tile.z & i > 0:
				out.append(Vector3(tile.x, tile.y, (i<<1) + 0))
				out.append(Vector3(tile.x, tile.y, (i<<1) + 1))
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
