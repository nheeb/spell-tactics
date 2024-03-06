class_name ImmediateArrows extends Node3D

const CIRCLE_SEGMENTS = 8
const ARROW_SCALE = 2.5
const BASE_LIFT = .35

enum ArrowEnd {
	Circle,
	Arrow,
	None
}

class Arrow:
	var start: Vector3
	var end: Vector3
	var width: float = .2
	var height: float = .04
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
				
		## Body - Top & Bottom
		#for hh in [-h,h]:
			#triangles.append(start + hh + w)
			#triangles.append(start + hh - w)
			#triangles.append(end + hh + w)
			#
			#triangles.append(end + hh - w)
			#triangles.append(end + hh + w)
			#triangles.append(start + hh - w)
		#
		## Body - Sides
		#for ww in [-w, w]:
			#triangles.append(start + ww + h)
			#triangles.append(start + ww - h)
			#triangles.append(end + ww + h)
			#
			#triangles.append(end + ww - h)
			#triangles.append(end + ww + h)
			#triangles.append(start + ww - h)
		
		return triangles

	func get_triangles_end(pos: Vector3, dir: Vector3, end_type: ArrowEnd) -> Array[Vector3]:
		var triangles : Array[Vector3] = []
		
		match end_type:
			ArrowEnd.Circle:
				var circle_start_dir := (dir * w.length()).rotated(Vector3.UP, - PI / 2)
				var angle_step := PI / (CIRCLE_SEGMENTS - 1)
				var circle_points : Array[Vector3] = []
				for i in range(CIRCLE_SEGMENTS):
					circle_points.append(pos + circle_start_dir.rotated(Vector3.UP, i * angle_step))
				for i in range(1, CIRCLE_SEGMENTS):
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
				var top := pos + dir * w.length() * ARROW_SCALE
				for ww in [-w, w]:
					var base : Vector3 = pos + ww
					var arm : Vector3 = pos + ww * ARROW_SCALE
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
