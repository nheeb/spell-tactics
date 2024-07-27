class_name CombatEventReference extends UniversalReference

@export var id: CombatEventID

var event: CombatEvent

func _init(_event: CombatEvent = null) -> void:
	if _event == null:
		return
	event = _event
	id = event.id
	assert(id, "CombatEventReference was created without ID.")

func connect_reference(combat: Combat) -> void:
	for e in combat.events.all_events:
		if not e.id:
			continue
		if e.id.equals(id):
			if event == e:
				push_error("SpellReference already connected to that object")
			else:
				if event != null:
					push_error("SpellReference already connected to another object")
			event = e
	if event == null:
		push_error("SpellReference did not get connected")

## Is being called by resolve and should never be called from outside.
func _resolve() -> Object:
	return event

func get_reference_type() -> String:
	return "CombatEventReference"
