class_name ImmediateArrows extends Node3D

static var CIRCLE_SEGMENTS := 8
static var ARROW_SCALE := 2.5
static var BASE_LIFT := .35
static var DEFAULT_WIDTH := .2
static var DEFAULT_HEIGHT := .04

enum ArrowEnd {
	Circle,
	Arrow,
	None
}

func _ready() -> void:
	DebugInfo.global_settings_config(ImmediateArrows, "Movement Arrow")
	DebugInfo.global_settings_add("CIRCLE_SEGMENTS")
	DebugInfo.global_settings_add("ARROW_SCALE", 1.0, 4.0)
	DebugInfo.global_settings_add("BASE_LIFT", 0.0, 2.0)
	DebugInfo.global_settings_add("DEFAULT_WIDTH", 0.05, .5)
	DebugInfo.global_settings_add("DEFAULT_HEIGHT", 0.01, .2)

class Arrow:
	var start: Vector3
	var end: Vector3
	var width: float = ImmediateArrows.DEFAULT_WIDTH
	var height: float = ImmediateArrows.DEFAULT_HEIGHT
	var tail: ArrowEnd = ArrowEnd.Circle
	var head: ArrowEnd = ArrowEnd.Circle

	var direction: Vector3
	var cross_direction: Vector3
	var h: Vector3
	var w: Vector3
	
	func calculate_util_variables() -> void:
		# Validate
		assert(start != end)
		assert(width > 0)
		assert(height > 0)
		
		# Util data
		direction = start.direction_to(end)
		cross_direction = Vector3.UP.cross(direction)
		
		h = Vector3.UP * height / 2.0
		w = cross_direction * width / 2.0

	func get_triangles_body() -> Array[Vector3]:
	# Create array
		var triangles : Array[Vector3] = []
		
		# Body (2 loop version)
		for offsets in [[h,w], [w,h]]:
			var a = offsets[0]
			var b = offsets[1]
			for aa in [-a, a]:
				triangles.append(start + aa + b)
				triangles.append(start + aa - b)
				triangles.append(end + aa + b)
				
				triangles.append(end + aa - b)
				triangles.append(end + aa + b)
				triangles.append(start + aa - b)
		
		return triangles

	func get_triangles_end(pos: Vector3, dir: Vector3, end_type: ArrowEnd) -> Array[Vector3]:
		var triangles : Array[Vector3] = []
		
		match end_type:
			ArrowEnd.Circle:
				var circle_start_dir := (dir * w.length()).rotated(Vector3.UP, - PI / 2)
				var angle_step := PI / (ImmediateArrows.CIRCLE_SEGMENTS - 1)
				var circle_points : Array[Vector3] = []
				for i in range(ImmediateArrows.CIRCLE_SEGMENTS):
					circle_points.append(pos + circle_start_dir.rotated(Vector3.UP, i * angle_step))
				for i in range(1, ImmediateArrows.CIRCLE_SEGMENTS):
					for hh in [-h, h]:
						triangles.append(pos + hh)
						triangles.append(circle_points[i-1] + hh)
						triangles.append(circle_points[i] + hh)
					triangles.append(circle_points[i] + h)
					triangles.append(circle_points[i-1] + h)
					triangles.append(circle_points[i] - h)
					triangles.append(circle_points[i-1] - h)
					triangles.append(circle_points[i] - h)
					triangles.append(circle_points[i-1] + h)
			ArrowEnd.Arrow:
				var top := pos + dir * w.length() * ImmediateArrows.ARROW_SCALE
				for ww in [-w, w]:
					var base : Vector3 = pos + ww
					var arm : Vector3 = pos + ww * ImmediateArrows.ARROW_SCALE
					triangles.append(base + h)
					triangles.append(base - h)
					triangles.append(arm + h)
					triangles.append(arm - h)
					triangles.append(arm + h)
					triangles.append(base - h)
					
					triangles.append(top + h)
					triangles.append(top - h)
					triangles.append(arm + h)
					triangles.append(arm - h)
					triangles.append(arm + h)
					triangles.append(top - h)
					
					triangles.append(top + h)
					triangles.append(arm + h)
					triangles.append(pos + h)
					triangles.append(top - h)
					triangles.append(pos - h)
					triangles.append(arm - h)
		return triangles

	func get_triangles_head() -> Array[Vector3]:
		return get_triangles_end(end, direction, head)

	func get_triangles_tail() -> Array[Vector3]:
		return get_triangles_end(start, -direction, tail)

	func get_triangles() -> Array[Vector3]:
		calculate_util_variables()
		var triangles : Array[Vector3] = []
		triangles.append_array(get_triangles_body())
		triangles.append_array(get_triangles_head())
		triangles.append_array(get_triangles_tail())
		return triangles

var arrow_list: Array[Arrow]

func set_path(path: Array[Vector3]) -> void:
	arrow_list.clear()
	for i in range(1, len(path)):
		var arrow = Arrow.new()
		arrow.start = path[i-1] + Vector3.UP * BASE_LIFT
		arrow.end = path[i] + Vector3.UP * BASE_LIFT
		arrow_list.append(arrow)
	arrow_list[-1].head = ArrowEnd.Arrow

func get_triangles() -> Array[Vector3]:
	var triangles : Array[Vector3] = []
	for arrow in arrow_list:
		triangles.append_array(arrow.get_triangles())
	return triangles

func render():
	var triangles := get_triangles()
	var ig : ImmediateMesh = $MeshInstance3D.mesh
	ig.clear_surfaces()
	ig.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for t in triangles:
		ig.surface_add_vertex(t)
	ig.surface_end()

func render_path(path: Array[Vector3]) -> void:
	set_path(path)
	render()

func clear() -> void:
	arrow_list.clear()
	var ig : ImmediateMesh = $MeshInstance3D.mesh
	ig.clear_surfaces()
