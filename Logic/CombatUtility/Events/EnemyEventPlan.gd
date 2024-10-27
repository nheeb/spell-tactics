class_name EnemyEventPlan extends Resource

@export var event_type: EnemyEventType
@export var params := {}
@export var override_meter_costs := 0
@export var event_created := false
## If this is true, the EventPlan will be copied when there are no other plans left
@export var use_as_default := false

func _init(_event_type: CombatEventType = null, _params := {}) -> void:
	event_type = _event_type
	params = _params

func create_event(combat: Combat) -> EnemyEvent:
	assert(combat and event_type and not event_created)
	event_created = true
	var event := event_type.create_event(combat, params)
	assert(event is EnemyEvent, "No EnemyEvent was created.")
	event.override_meter_costs = override_meter_costs
	return event
