class_name EntityID extends Resource

@export var type: EntityType
@export var id: int

func _to_string() -> String:
	return "<%s:%s>" % [type.pretty_name, id]

func equals(other_id: EntityID) -> bool:
	return type == other_id.type and id == other_id.id

func _init(t: EntityType = null, i: int = 0) -> void:
	type = t
	id = i
	
