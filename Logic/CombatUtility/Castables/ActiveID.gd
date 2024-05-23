class_name ActiveID extends Resource

@export var id : int

func equals(other_id: ActiveID) -> bool:
	return id == other_id.id

func _to_string() -> String:
	return "<Active:%s>" % id

func _init(_id := 0) -> void:
	id = _id
