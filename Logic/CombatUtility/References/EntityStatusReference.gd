class_name EntityStatusReference extends CallbackReference

func _init(entity_ref: EntityReference = null, status_name: String = "") -> void:
	origin_reference = entity_ref
	method_name = "get_status_effect"
	params = [status_name]
	cache_result = false

func get_reference_type() -> String:
	return "EntityStatusReference"
