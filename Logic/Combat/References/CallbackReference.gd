class_name CallbackReference extends UniversalReference

@export var origin_reference: UniversalReference
@export var method_name: String
@export var params: Array

var obj: Object

func _init(_origin_reference: UniversalReference = null, _method_name: String = "", _params := []) -> void:
	origin_reference = _origin_reference
	method_name = _method_name
	params = _params
	cache_result = false

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	var origin_node = origin_reference.resolve(combat)
	assert(origin_node)
	obj = origin_node.callv(method_name, params)

## Is being called by resolve and should never be called from outside.
func _resolve() -> Variant:
	return obj

func get_reference_type() -> String:
	return "CallbackReference"
