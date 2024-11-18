class_name CombatObjectState extends Resource

## Data is seperated from the other properties to make it easier to edit
@export var data: Dictionary
## All other export properties of the CombatObject 
@export var props: Dictionary
## A flag saving if this was ever deserialized
@export var was_deserialized := false

func _init(object: CombatObject = null) -> void:
	if object:
		data = object.data
		for export_prop in Utility.get_exported_properties(object):
			if export_prop == "data":
				continue
			props[export_prop] = object.get(export_prop)

func get_creation_props() -> Dictionary:
	var creation_props := {}
	var type := get("type") as CombatObjectType
	if type:
		creation_props["type"] = type
	return creation_props

func deserialize(combat: Combat) -> CombatObject:
	# Integrate data into props
	if "data" in props.keys():
		push_warning("CombatObjectState: Data should always kept seperate.")
	props["data"] = data
	# Get creation props
	if not object_was_born_before():
		props.merge(get_creation_props(), true)
	# Set deserialized flag
	if was_deserialized:
		push_warning("CombatObjectState was already deserialized: %s" % props)
	was_deserialized = true
	# Get type
	var type := props.get("type") as CombatObjectType
	if type == null:
		push_error("No type given for standard TypedObject creation.")
		return null
	# Create object
	return type.create(combat, props)

func object_was_born_before() -> bool:
	return props.get("born", false) as bool
