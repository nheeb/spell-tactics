class_name CombatObjectReference extends UniversalReference

@export var id: int

var object: CombatObject

func _init(_object: CombatObject = null) -> void:
	if _object:
		object = _object
		id = object.id
		assert(id >= 0, "EntityReference was created on an entity with empty id")

func connect_reference(combat: Combat) -> void:
	object = combat.ids.combat_objects.get(id)
	if not object:
		push_error("CombatObjectReference did not get connected")

## Is being called by resolve and should never be called from outside.
func _resolve() -> Variant:
	return object

func get_reference_type() -> String:
	return "CombatObjectReference"
