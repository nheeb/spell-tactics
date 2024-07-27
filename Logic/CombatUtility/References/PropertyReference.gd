class_name PropertyReference extends UniversalReference

@export var origin_reference: UniversalReference
@export var property_name: String

var obj: Object

func _init(_origin_reference: UniversalReference = null, _property_name: String = "") -> void:
	origin_reference = _origin_reference
	property_name = _property_name

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	var origin_node = origin_reference.resolve(combat)
	obj = origin_node.get(property_name)

## Is being called by resolve and should never be called from outside.
func _resolve() -> Variant:
	return obj

func get_reference_type() -> String:
	return "PropertyReference"
