class_name EnemyEventPlan extends CombatObjectState

@export var type: EnemyEventType
var event_type: EnemyEventType:
	get:
		return type
@export var override_meter_costs := 0
## If this is true, the EventPlan will be copied when there are no other plans left
@export var use_as_default := false

func get_template_props() -> Dictionary:
	var p := super()
	if override_meter_costs > 0:
		p["override_meter_costs"] = override_meter_costs
	return p

func create_event(combat: Combat) -> EnemyEvent:
	return deserialize(combat)
