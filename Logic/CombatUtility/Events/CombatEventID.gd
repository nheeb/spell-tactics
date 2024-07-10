class_name CombatEventID extends Resource

@export var id : int

func equals(other_id: CombatEventID) -> bool:
	return id == other_id.id

func _to_string() -> String:
	return "<CombatEvent:%s>" % id

func _init(_id := 0) -> void:
	id = _id
