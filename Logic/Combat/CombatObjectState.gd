class_name CombatObjectState extends Resource

@export var props: Dictionary

func _init(object: CombatObject = null) -> void:
	if object:
		for export_prop in Utility.get_exported_properties(object):
			props[export_prop] = object.get(export_prop)

func deserialize(combat: Combat) -> CombatObject:
	var type := props.get("type") as CombatObjectType
	if type == null:
		push_error("No type given for standard TypedObject creation.")
		return null
	return type.create(combat, props)
