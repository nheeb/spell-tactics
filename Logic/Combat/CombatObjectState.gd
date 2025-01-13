class_name CombatObjectState extends Resource
## CombatObjectState is a generic Resource to serialize a CombatObject.
## When created it saves all the CombatObject's exportet properties.
## This is NOT just used for saving the game. A CombatObjectState can be used as template as well.
## If it is a template use create(), otherwise use deserialize()

## Data is seperated from the other properties to make it easier to edit
@export var data: Dictionary
## All other export properties of the CombatObject 
@export var props: Dictionary
## A flag saving if this was ever deserialized
@export var was_deserialized := false
@export var _deserialize_count := 0

func _init(object: CombatObject = null) -> void:
	if object:
		data = object.data
		for export_prop in Utility.get_exported_properties(object):
			if export_prop == "data":
				continue
			props[export_prop] = object.get(export_prop)

## Returns the properties that should be added when the COS is a template. (Mainly the type)
## By overriding this you can add new export vars for easy template editing. (see EnemyEventPlan)
func get_template_props() -> Dictionary:
	var template_props := {}
	var type := get("type") as CombatObjectType
	if type:
		template_props["type"] = type
	return template_props

func deserialize(combat: Combat) -> CombatObject:
	# Integrate data into props
	if "data" in props.keys():
		push_warning("CombatObjectState: Data should always kept seperate.")
	props["data"] = data
	# Get creation props
	if is_template():
		props.merge(get_template_props(), true)
	# Set deserialized flag
	# TBD do we want this warning?
	#if was_deserialized:
		#push_warning("CombatObjectState was already deserialized: %s" % props)
	was_deserialized = true
	_deserialize_count += 1
	# Get type
	var type := props.get("type") as CombatObjectType
	if type == null:
		push_error("No type given for standard TypedObject creation.")
		return null
	# Create object
	return type.create(combat, props)

## Wrapper for deserialize that warns if the Object was once serialized.
## This is intended to be used for States created in the inspector.
func create(combat: Combat) -> CombatObject:
	if not is_template():
		push_warning("Creating CombatObject that was serialized before.")
		push_warning("If this is intended use 'deserialize' instead.")
	return deserialize(combat)

## Returns if the CombatObjectState is a tamplate. Otherwise it's a save state.
func is_template() -> bool:
	return not (props.get("born", false) as bool)
