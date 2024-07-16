class_name CombatEventSchedule extends Resource

@export var event_type: CombatEventType
@export var params := {}
@export var event_created := false

func set_scheduled_round(combat: Combat, value: int) -> void:
	if combat:
		combat.events.add_event_schedule(self, value)

func get_scheduled_round(combat: Combat) -> int:
	if combat:
		return combat.events.get_event_schedule_round_number(self)
	return 0

func _init(_event_type: CombatEventType = null, _params := {}) -> void:
	event_type = _event_type
	params = _params

func create_event(combat: Combat) -> CombatEvent:
	assert(combat and event_type and not event_created)
	event_created = true
	return event_type.create_event(combat, params)
