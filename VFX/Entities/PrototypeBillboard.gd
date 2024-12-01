class_name PrototypeBillboard extends Node3D

static var all_files: Array[String]
static func get_all_billboard_files() -> Array[String]:
	if all_files:
		return all_files
	var dir = DirAccess.open(Game.PROTOTYPE_BILLBOARD_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				push_warning("Prototype Billboards: %s is a directory." % file_name)
			elif file_name.ends_with(".import"):
				pass
			elif not file_name.ends_with(".png"):
				push_warning("Prototype Billboards: %s is not a png." % file_name)
			else:
				all_files.append(Game.PROTOTYPE_BILLBOARD_DIR + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return all_files

static func has_billboard_texture(entity_name: String) -> bool:
	#return FileAccess.file_exists(get_billboard_filepath(entity_name))
	var path := get_billboard_filepath(entity_name)
	if path:
		return load(path) != null
	return false

static func get_billboard_filepath(entity_name: String) -> String:
	var possible_texture_names: Array[String] = []
	for tex_name in [entity_name, entity_name.to_lower(), entity_name.to_snake_case()]:
		possible_texture_names.append(Game.PROTOTYPE_BILLBOARD_DIR + tex_name + ".png")
	var _all_files := get_all_billboard_files()
	possible_texture_names = possible_texture_names.filter(
		func (full_path: String):
			return full_path in _all_files
	)
	if possible_texture_names:
		return possible_texture_names.front()
	return ""

func set_texture(path: String) -> void:
	$Quad.material_override.set("shader_parameter/texture_albedo", load(path))

func set_modulate(color: Color) -> void:
	$Quad.material_override.set("shader_parameter/albedo", color)

func set_texture_from_entity_name(entity_name: String) -> void:
	set_texture(PrototypeBillboard.get_billboard_filepath(entity_name))

func drain_transition(drained: bool = true) -> void:
	VisualTime.new_tween().tween_property($Quad.material_override, "shader_parameter/drain_progress", float(drained), 0.8)
