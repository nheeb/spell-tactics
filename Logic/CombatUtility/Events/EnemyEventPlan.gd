class_name EnemyEventPlan extends Resource

@export var event_type: EnemyEventType
@export var params := {}
@export var event_created := false

func _init(_event_type: CombatEventType = null, _params := {}) -> void:
	event_type = _event_type
	params = _params

func create_event(combat: Combat) -> EnemyEvent:
	assert(combat and event_type and not event_created)
	event_created = true
	return event_type.create_event(combat, params)
