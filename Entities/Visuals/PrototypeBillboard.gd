@tool
class_name PrototypeBillboard extends Node3D

static func has_billboard_texture(entity_name: String) -> bool:
	return FileAccess.file_exists(get_billboard_filepath(entity_name))

static func get_billboard_filepath(entity_name) -> String:
	return Game.PROTOTYPE_BILLBOARD_DIR + entity_name + ".png"

func set_texture(path: String) -> void:
	$MeshInstance3D.material_override.set("albedo_texture", load(path))

func set_texture_from_entity_name(entity_name: String) -> void:
	set_texture(PrototypeBillboard.get_billboard_filepath(entity_name))
