class_name PrototypeBillboard extends Node3D

static func has_billboard_texture(entity_name: String) -> bool:
	#return FileAccess.file_exists(get_billboard_filepath(entity_name))
	return load(get_billboard_filepath(entity_name)) != null

static func get_billboard_filepath(entity_name: String) -> String:
	return Game.PROTOTYPE_BILLBOARD_DIR + entity_name.to_snake_case() + ".png"

func set_texture(path: String) -> void:
	$Quad.material_override.set("shader_parameter/texture_albedo", load(path))

func set_texture_from_entity_name(entity_name: String) -> void:
	set_texture(PrototypeBillboard.get_billboard_filepath(entity_name))

func drain_transition(drained: bool = true) -> void:
	VisualTime.new_tween().tween_property($Quad.material_override, "shader_parameter/drain_progress", float(drained), 0.8)
