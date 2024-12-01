class_name GeneralUtilityClass extends Node

#########################
## Number Calculations ##
#########################

func clamp_map(value: float, istart: float, istop: float, ostart: float, ostop: float) -> float:
	value = clamp(value, istart, istop)
	return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))

func clamp_map_pow(value: float, istart: float, istop: float, ostart: float, ostop: float, e: float) -> float:
	var middle = pow(clamp_map(value, istart, istop, 0.0, 1.0), e)
	return lerp(ostart, ostop, middle)

func positive_angle(radians: float) -> float:
	return fposmod(radians, TAU)

#############
## Vectors ##
#############

func remove_y_value(pos: Vector3) -> Vector3:
	pos.y = 0.0
	return pos

func no_y_normalized(vec: Vector3) -> Vector3:
	return remove_y_value(vec).normalized()

func y_plane_dist(pos1: Vector3, pos2: Vector3) -> float:
	return remove_y_value(pos1).distance_to(remove_y_value(pos2))

func vec_xy_to_vec3(v: Vector2, z := 0.0) -> Vector3:
	return Vector3(v.x, v.y, z)

func vec3_discard_z(v: Vector3) -> Vector2:
	return Vector2(v.x, v.y)

func quadratic_bezier_3D(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r

#############
## Strings ##
#############

## Returns the first substring between left and right
func string_beween(s: String, left: String, right: String) -> String:
	if left not in s or right not in s: return ""
	return s.split(left)[1].split(right)[0]

###########
## Nodes ##
###########

## Rotates a node3d so that the local_direction alligns with target_global_direction
func align_node(node: Node3D, local_direction: Vector3, target_global_direction: Vector3):
	var current_global_direction := node.global_position.direction_to(node.to_global(local_direction))
	var cross_direction := current_global_direction.cross(target_global_direction).normalized()
	if cross_direction.is_normalized():
		var rotation_angle := current_global_direction.signed_angle_to(target_global_direction, cross_direction)
		node.rotate(cross_direction, rotation_angle)

func recursive_set_light_layers(node: Node, layers: int):
	for c in node.get_children():
		recursive_set_light_layers(c, layers)
		if c is VisualInstance3D:
			(c as VisualInstance3D).layers = layers

func get_recursive_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var mesh_instances : Array[MeshInstance3D] = []
	for c in node.get_children():
		mesh_instances.append_array(get_recursive_mesh_instances(c))
		if c is MeshInstance3D:
			mesh_instances.append(c)
	return mesh_instances

func get_parent_of_type(n: Node, type) -> Node:
	var parent: Node = n.get_parent()
	while parent:
		if is_instance_of(parent, type):
			return parent
		parent = parent.get_parent()
	push_error("No parent of %s with type %s found." % [n, type])
	return null

##############
## Hex Grid ##
##############

func cube_add(r1: int, q1: int, s1: int, r2: int, q2: int, s2: int) -> Vector3i:
	return Vector3i(r1 + r2, q1 + q2, s1 + s2)

## Hex distance using rq coordinates
func rq_distance(r1: int, q1: int, r2: int, q2: int) -> int:
	return (abs(q1 - q2) 
			+ abs(q1 + r1 - q2 - r2)
			+ abs(r1 - r2)) / 2

################
## Randomness ##
################

var random_index_of_scores_report: String
func random_index_of_scores(scores: Array, create_report := false, \
							names: Array = [], title := "") -> int:
	if scores.is_empty():
		push_error("Random index: Empty list")
		return -1
	var total_size : float = scores.reduce(func(a,b): return a + b, 0.0)
	if total_size == 0.0:
		push_error("Random index: Only Zero entries")
		return -1
	var random_value := randf_range(0.0, total_size)
	var chosen_index: int = -1
	for i in range(scores.size()):
		random_value -= scores[i]
		if random_value < 0.0:
			chosen_index = i
			break
	if chosen_index == -1:
		push_error("Random index: Something went wrong")
	if create_report:
		var report := "%s:\n" % title
		var index_order := range(scores.size())
		index_order.sort_custom(
			func (a,b):
				return scores[a] > scores[b]
		)
		for index in index_order:
			report += "%s %4.1f%% %s\n" % [
				"->" if index == chosen_index else "  ",
				100.0 * scores[index] / total_size , names[index]
			]
		random_index_of_scores_report = report
	return chosen_index

## the hit chance should be between 0 and 100
func random_hit(hit_chance: float) -> bool:
	hit_chance = clamp(hit_chance, 0.0, 100.0)
	#assert(hit_chance >= 0.0 and hit_chance <= 100.0)
	return randf() <= (hit_chance * 0.01)

func random_hash(length:int, chars := "abcdefghijklmnopqrstuvwxyz") -> String:
	var word: String = ""
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word

func random_direction() -> Vector3:
	return Vector3.UP.rotated(Vector3.FORWARD, TAU * randf())\
					 .rotated(Vector3.UP, TAU * randf())

############
## Arrays ##
############

## Returns a copy of the array with only unique and non null values
func array_unique(array: Array, no_null_values := true) -> Array:
	var unique: Array = []
	for item in array:
		if no_null_values and item == null:
			continue
		if not unique.has(item):
			unique.append(item)
	return unique

## Get an array element with default value instead of error if index is out of bounds
func array_safe_get(array: Array, index: int, mirror := false, default = null) -> Variant:
	if mirror:
		while not index < len(array):
			index -= len(array)
		while not index >= -len(array):
			index += len(array)
	if index >= -len(array) and index < len(array):
		return array[index]
	else:
		return default

## Sorts the given array. In contrary to Array.sort_custom(Callable)
## this takes a callable with just one parameter which should turn each elements
## into number. The elements are sorted based on that.
func array_sort(array: Array, score_func: Callable, asc := true) -> void:
	array.sort_custom(
		func (a, b) -> bool:
			var score_a := score_func.call(a) as float
			var score_b := score_func.call(b) as float
			return score_a < score_b
	)
	if not asc:
		array.reverse()

## Returns a sorted version of the array.
## Takes a callable which should turn the elements into numbers.
func array_sorted(array: Array, score_func: Callable, asc := true) -> Array:
	var _array := array.duplicate()
	array_sort(_array, score_func, asc)
	return _array

func array_shuffled(array: Array) -> Array:
	var _array := array.duplicate()
	_array.shuffle()
	return _array

func array_sum(array: Array) -> Variant:
	return array.reduce(func(a,b): return a+b)

func array_average(array: Array) -> float:
	return array_sum(array) * (1.0 / array.size())

## Returns the value if it's an array, puts it into an array otherwise
func array_from(value: Variant) -> Array:
	if value is Array:
		return value
	return [value]

## Flattens an array which might contain other arrays.
func array_flat(array: Array) -> Array:
	if array.all(func (x): return x is not Array):
		return array.duplicate()
	var result := []
	for item in array:
		if item is Array:
			var flat := array_flat(item)
			result.append_array(item)
		else:
			result.append(item)
	return result

###########
## Dicts ##
###########

func dict_safe_get(dict: Dictionary, key: Variant, default = null) -> Variant:
	return dict.get(key, default)

###########
## Flags ##
###########

func has_int_flag(flags: int, target_flag: int) -> bool:
	return (flags & target_flag) == target_flag

func add_int_flag(flags: int, target_flag: int) -> int:
	return flags | target_flag

func remove_int_flag(flags: int, target_flag: int) -> int:
	return flags & (~target_flag)

#################
## Game Screen ##
#################

func take_screenshot(shrink_count := 0) -> ImageTexture:
	var image := Game.get_viewport().get_texture().get_image()
	for i in range(shrink_count):
		image.shrink_x2()
	#image.compress(Image.COMPRESS_ASTC)
	var texture := ImageTexture.create_from_image(image)
	return texture
	
## for when the viewport resolution doesn't match the content_scale	
func scale_screen_pos(screen_pos: Vector2) -> Vector2:
	var current_viewport_size: Vector2 = get_tree().root.size
	var reference_viewport_size: Vector2 = get_tree().root.content_scale_size
	var viewport_scale: Vector2 = current_viewport_size / reference_viewport_size
	var size_scale: float = minf(viewport_scale.x, viewport_scale.y)
	#var scaled: Vector2 = Vector2(viewport_scale.x * screen_pos.x, viewport_scale.y * screen_pos.y)
	var scaled: Vector2 = screen_pos * size_scale
	return scaled

func get_mouse_pos_absolute() -> Vector2:
	return get_viewport().get_mouse_position()

func get_mouse_pos_normalized(invert_y_axis := true) -> Vector2:
	var absolute := get_mouse_pos_absolute()
	if invert_y_axis:
		return Vector2(absolute.x / get_viewport().get_visible_rect().size.x, 1.0 - (absolute.y / get_viewport().get_visible_rect().size.y))
	else:
		return Vector2(absolute.x / get_viewport().get_visible_rect().size.x, absolute.y / get_viewport().get_visible_rect().size.y)

#############
## Signals ##
#############

func disconnect_all_connections(s: Signal):
	for c in s.get_connections():
		s.disconnect(c["callable"])

## Creates a signal without needing to bind it to an instance. This means the signal can be
## assigned to a static var and accessed globally. `cls` should be a global class identifier. 
## Taken from https://stackoverflow.com/questions/77026156/how-to-write-a-static-event-emitter-in-gdscript
static func create_static_signal(cls: Object, signal_name: StringName) -> Signal:
	if not cls.has_user_signal(signal_name):
		cls.add_user_signal(signal_name)
	return Signal(cls, signal_name)

###########
## Debug ##
###########

## Turns a stack trace object into readable lines.
## stack_trace is an Array with dicts having function, line and source
func get_stack_trace_lines(stack_trace: Array[Dictionary], exclude_front_elements: Array[String], \
		add_script_line := true) -> PackedStringArray:
			var result := PackedStringArray([])
			for stack_element in stack_trace:
				var source: String = stack_element["source"].split("/")[-1]
				var line: int = stack_element["line"]
				var function: String = stack_element["function"]
				var string := "%18s [%d] -> %s:" % [source, line, function]
				if result.is_empty():
					if exclude_front_elements.any(func(x): return x in string):
						continue
				result.append(string)
				if add_script_line:
					var script: GDScript = load(stack_element["source"])
					var script_lines := script.source_code.split("\n")
					var script_line := script_lines[line-1].strip_edges()
					result.append("\t" + script_line)
				result.append("")
			return result

#############
## Scripts ##
#############

## Returns the method names of methods actually written / typed in the script.
## So no methods from the base class except overwritten ones.
func script_get_actual_method_names(script: Script) -> Array[String]:
	var a: Array[String] = []
	a.append_array(Array(script.source_code.split("\n")).filter(
		func (x: String): return x.strip_edges().begins_with("func ")
	).map(
		func (x: String): return string_beween(x.strip_edges(), "func ", "(")
	).filter(
		func (x: String): return not x.is_empty()
	))
	return a

func script_has_actual_method(script: Script, method: String) -> bool:
	return method in script_get_actual_method_names(script)

func get_exported_properties(object: Object) -> Array[String]:
	var exported_properties: Array[String] = []
	var script: Script = object.get_script()
	if script:
		var properties = script.get_script_property_list()
		for property in properties:
			if "usage" in property and property["usage"] & PROPERTY_USAGE_STORAGE:
				exported_properties.append(property["name"])
	return exported_properties
