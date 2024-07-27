extends Node

var current_animations: Array[AnimationObject]

const SHOW_ENEMY_PROJECTILE_INFO = true

#####################
## Global Settings ##
#####################

class GlobalSettingsEntry:
	var attr_name: String
	var default
	var range_start
	var range_end
	var use_range := false
	var obj_list: Array
	var text: String
	var changed_value
	var changed := false
	
	func _init(attr: String, first_object = null) -> void:
		attr_name = attr
		obj_list = []
		if first_object != null:
			add_obj(first_object)
	
	func set_range(start, end):
		range_start = start
		range_end = end
		use_range = true
	
	func get_clean_objects() -> Array:
		obj_list = obj_list.filter(func(x): return is_instance_valid(x))
		return obj_list
	
	func refresh() -> void:
		var values := get_clean_objects().map(func (x): return x.get(attr_name))
		default = values[0]
		if values.min() != values.max():
			text = "%s - %s" % [values.min(), values.max()]
		else:
			text = str(default)
	
	func set_value(value):
		value = cast_to_default(value)
		changed = true
		changed_value = value
		text = str(changed_value)
		for obj in obj_list:
			obj.set(attr_name, value)
	
	func get_value():
		return changed_value if changed else default
	
	func cast_to_default(value):
		match typeof(default):
			TYPE_INT:
				return int(value)
			TYPE_FLOAT:
				return float(value)
			TYPE_BOOL:
				return bool(value)
			TYPE_STRING:
				return str(value)
		return 0
	
	func add_obj(obj):
		if obj in obj_list:
			return
		obj_list.append(obj)
		if changed:
			set_value(changed_value)
		else:
			refresh()

	func reset():
		set_value(default)
		changed = false

## String(Foldername) -> Dict{String(Attributename) -> GlobalSettingEntry}
var global_settings_folders := {}
var global_settings_current_folder := "General Settings"
var global_settings_current_obj = null

func global_settings_config(obj, folder_name: String):
	global_settings_current_obj = obj
	global_settings_current_folder = folder_name

func global_settings_add(attr_name, range_start := 0.0, range_end := 0.0):
	if not global_settings_current_folder in global_settings_folders:
		global_settings_folders[global_settings_current_folder] = {}
	var attr_dict: Dictionary = global_settings_folders[global_settings_current_folder]
	if not attr_name in attr_dict.keys():
		attr_dict[attr_name] = GlobalSettingsEntry.new(attr_name)
	attr_dict[attr_name].add_obj(global_settings_current_obj)
	if range_start != range_end:
		attr_dict[attr_name].set_range(range_start, range_end)

func global_settings_get_entry(folder, attr) -> GlobalSettingsEntry:
	if not folder in global_settings_folders:
		push_error("Gloabal Settings: Get objects with wrong folder")
		return null
	if not attr in global_settings_folders[folder].keys():
		push_error("Gloabal Settings: Get objects with wrong attr")
		return null
	return global_settings_folders[folder][attr]

func global_settings_get_connected_objects(folder, attr) -> Array:
	return global_settings_get_entry(folder, attr).get_clean_objects()

func global_settings_change(folder, attr, value):
	global_settings_get_entry(folder, attr).set_value(value)
