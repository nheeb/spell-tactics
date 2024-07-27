class_name CallableReference extends UniversalReference

@export var origin_reference: UniversalReference
@export var method_name: String

var callable: Callable

func _init(_origin_reference: UniversalReference = null, _method_name: String = "") -> void:
	origin_reference = _origin_reference
	method_name = _method_name
	cache_result = false

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	var origin_node = origin_reference.resolve(combat)
	callable = origin_node.get(method_name)

## Is being called by resolve and should never be called from outside.
func _resolve() -> Variant:
	return callable

func get_reference_type() -> String:
	return "CallableReference"

static func from_callable(callable: Callable) -> CallableReference:
	var obj = callable.get_object()
	if obj.has_method("get_reference"):
		return CallableReference.new(obj.get_reference(), callable.get_method())
	push_error("Invalid Callable to make a reference")
	return null
