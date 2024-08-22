class_name Inspector extends Control

static var translate_blocker: Utils.Blocker = GameCamera.translate_block.register_blocker()


# TODO different property filters maybe.. can we deal with inheritance + properties? hmm
static func get_exported_properties(node: Node) -> Array:
	var exported_properties = []
	var script = node.get_script()
	
	if script:
		var properties = script.get_script_property_list()
		for property in properties:
			if "usage" in property and property["usage"] & PROPERTY_USAGE_STORAGE:
				var prop_info = {
					"name": property["name"],
					"type": type_string(property["type"]),
					"origin_class": get_property_origin_class(script, property["name"]),
					"value": node.get(property["name"])
				}
				
				# Check if it's a numeric range
				if property["hint"] == PROPERTY_HINT_RANGE:
					var range_info = property["hint_string"].split(",")
					if range_info.size() >= 3:
						prop_info["min"] = float(range_info[0])
						prop_info["max"] = float(range_info[1])
						prop_info["step"] = float(range_info[2])
				
				exported_properties.append(prop_info)
	
	return exported_properties

static func get_property_origin_class(script: GDScript, property_name: String) -> String:
	var current_class = script
	while current_class:
		var properties = current_class.get_script_property_list()
		for property in properties:
			if property["name"] == property_name:
				return current_class.get_path().get_file().get_basename()
		current_class = current_class.get_base_script()
	return "Unknown"


var entity: Entity

func _on_value_focus_entered() -> void:
	translate_blocker.block()

func _on_value_focus_exited() -> void:
	translate_blocker.unblock()

func inspect_entity(ent: Entity, idx: int = -1):
	# inspect both logical and visual? 
	# let's start with visual
	entity = ent
	$%EntityName.text = ent.to_string()
	var props = get_exported_properties(ent.visual_entity)
	print(props)
	
	for prop_control in $%Rows.get_children():
		prop_control.queue_free()
	
	for prop in props:
		add_prop(prop)

func inspect_different_entity():
	pass


const PropNameScene = preload("res://Logic/LevelEditor/UI/InspectorPropName.tscn")  # left column
const PropValueSceneDefault = preload("res://Logic/LevelEditor/UI/InspectorPropName.tscn")  # right column

func type_to_control(type: String):
	match type:
		"float":
			return PropValueSceneDefault
		_:
			return PropValueSceneDefault

func parse_value(value: Variant, type: String):
	match type:
		"float":
			value = float(value)
		"String":
			pass
		"int":
			value = int(value)
		_:
			push_error("unknown type")
	return value

func prop_changed(value: String, prop_name: String, type: String):
	assert(entity != null, "Must have an entity")
	assert(prop_name in entity.visual_entity)
	
	entity.visual_entity.set(prop_name, parse_value(value, type))
	print("%s set %s = %s" % [entity, prop_name, str(parse_value(value, type))])

func add_prop(prop: Dictionary):
	var name_control = PropNameScene.instantiate()
	var value_control = type_to_control(prop["type"]).instantiate()
	value_control.focus_entered.connect(_on_value_focus_entered)
	value_control.focus_exited.connect(_on_value_focus_exited)
	value_control.text_changed.connect(prop_changed.bind(prop["name"], prop["type"]))
	name_control.text = prop["name"]
	value_control.text = str(prop["value"])
	$%Rows.add_child(name_control)
	$%Rows.add_child(value_control)
