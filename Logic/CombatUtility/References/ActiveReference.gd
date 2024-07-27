class_name ActiveReference extends UniversalReference

@export var id: ActiveID

var active: Active

func _init(_active: Active = null) -> void:
	if _active == null:
		return
	active = _active
	id = _active.id
	if id == null:
		push_error("ActiveReference was created on an active with empty id")

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	for s in combat.get_all_actives():
		if not s.id:
			continue
		if s.id.equals(id):
			if active == s:
				push_error("ActiveReference already connected to that object")
			else:
				if active != null:
					push_error("ActiveReference already connected to another object")
			active = s
	if active == null:
		push_error("ActiveReference did not get connected")

## Is being called by resolve and should never be called from outside.
func _resolve() -> Object:
	return active

func get_reference_type() -> String:
	return "ActiveReference"
