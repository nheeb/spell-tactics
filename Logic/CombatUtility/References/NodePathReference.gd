class_name NodePathReference extends UniversalReference

@export var origin_reference: UniversalReference
@export var node_path: String

var node: Node

func _init(_origin_reference: UniversalReference = null, _node_path: String = "") -> void:
	origin_reference = _origin_reference
	node_path = _node_path

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	var origin_node = origin_reference.resolve(combat)
	assert(origin_node is Node)
	node = origin_node.get_node(node_path)

## Is being called by resolve and should never be called from outside.
func _resolve() -> Object:
	return node

func get_reference_type() -> String:
	return "NodePathReference"
