class_name CombatObjectReference extends UniversalReference

@export var id: int
@export var removed := false

var object: CombatObject

## Just for debugging in inspector
var object_name: String:
	get:
		if object:
			return object.combat.ids.object_names[id]
		return ""

func _init(_object: CombatObject = null) -> void:
	if _object:
		object = _object
		id = object.id
		assert(id >= 0, "CombatObjectReference was created on an entity with empty id")

func connect_reference(combat: Combat) -> void:
	object = combat.ids.get_object(id)
	if not object:
		push_error("CombatObjectReference did not get connected")

## Is being called by resolve and should never be called from outside.
func _resolve() -> Variant:
	if removed:
		push_warning("Resolving reference for removed object: %s" % str(object))
	return object

func get_reference_type() -> String:
	return "CombatObjectReference"
