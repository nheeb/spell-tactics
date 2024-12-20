class_name SelectionUI extends Control

@export var editor_ui: EditorUI = null

enum Mode {
	None,
	Terrain,
	Entities
}

var container: Container
var _mode: Mode

func _ready():
	if editor_ui:
		editor_ui.selection_ui = self
	container = get_node("ScrollContainer/Container")
	call_deferred("set_mode", Mode.Terrain)

func set_mode(mode: Mode):
	_mode = mode
	for child in container.get_children():
		child.queue_free()
	
		
	if mode == Mode.Terrain:
		_add("None", null)
	for type in _get_entities_of_type(mode):
		_add(type.internal_name, type)
	
	
func _get_entities_of_type(mode: Mode) -> Array[EntityType]:
	var result: Array[EntityType] = []
	if mode == Mode.None:
		return result
	
	var files: Array[String] = _get_all_file_paths("res://Content/Entities/")
	files.append_array(_get_all_file_paths("res://Content/Enemies/Types/"))
	files.append_array(_get_all_file_paths("res://Content/Player/"))
	for file: String in files:
		if not file.ends_with(".tres"):
			continue
		var entity_type := load(file) as EntityType
		if entity_type == null:
			push_warning("Could not load file %s. It may not be an EntityType." % file)
			continue
		entity_type.on_load()
		if entity_type == null: # loaded anbother Resource type, ignore this
			continue
		if mode == Mode.Terrain and not entity_type.is_terrain:
			continue
		if mode == Mode.Entities and entity_type.is_terrain:
			continue
		result.append(entity_type)
	return result
	
	
func _get_all_file_paths(path: String) -> Array[String]:
	while path.ends_with("/"):
		path = path.trim_suffix("/")
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name
		if dir.current_is_dir():
			file_paths += _get_all_file_paths(file_path)
		else:
			file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths

func _add(_name: String, res: EntityType):
	var item = preload("res://Logic/LevelEditor/UI/SelectionItem.tscn").instantiate()
	item.display_name = _name
	item.res = res
	item.editor_ui = editor_ui
	item.mode = _mode
	container.add_child(item)
