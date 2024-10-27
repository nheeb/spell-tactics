class_name SpellID extends Resource

@export var id : int

func equals(other_id: SpellID) -> bool:
	return id == other_id.id

func _to_string() -> String:
	return "<Spell:%s>" % id

func _init(_id := 0) -> void:
	id = _id
