class_name CombatNodeReference extends NodePathReference

func _init(_node_path: String = "") -> void:
	origin_reference = CombatReference.new()
	node_path = _node_path

func get_reference_type() -> String:
	return "CombatNodeReference"
