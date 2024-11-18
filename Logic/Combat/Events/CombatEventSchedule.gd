class_name CombatEventSchedule extends CombatObjectState

@export var type: CombatEventType
var event_type: CombatEventType:
	get:
		return type
@export var scheduled_round := 0

static func from_type(cet: CombatEventType, data := {}, round := 0) -> CombatEventSchedule:
	var ces := CombatEventSchedule.new()
	ces.type = cet
	ces.scheduled_round = round
	ces.data = data
	return ces

func create_event(combat: Combat) -> CombatEvent:
	return deserialize(combat)
