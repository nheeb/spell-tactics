class_name CombatEventSchedule extends Resource

@export var event_type: CombatEventType
@export var params := {}
@export var event_created := false
@export var scheduled_round := 0

func _init(cet: CombatEventType = null, _params := {}, _round := 0) -> void:
	event_type = cet
	params = _params
	scheduled_round = _round

func create_event(combat: Combat) -> CombatEvent:
	assert(combat and event_type and not event_created)
	event_created = true
	return event_type.create_event(combat, params)
