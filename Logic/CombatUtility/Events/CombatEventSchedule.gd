class_name CombatEventSchedule extends Resource

var combat: Combat
@export var event_type: CombatEventType
@export var params := {}
@export var event_created := false
var scheduled_round: int:
	set(x):
		if combat:
			combat.event.add_event_schedule(self, x)
	get:
		if combat:
			return combat.event.get_event_schedule_round_number(self)
		return 0

func _init(_combat: Combat, _event_type: CombatEventType, _params := {}) -> void:
	combat = _combat
	event_type = _event_type
	params = _params

func create_event() -> CombatEvent:
	assert(combat and event_type and not event_created)
	event_created = true
	return event_type.create_event(combat, params)
