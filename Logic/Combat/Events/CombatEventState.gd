class_name CombatEventState extends CombatObjectState

@export var type: CombatEventType
@export var params := {}
@export var active: bool = false
@export var finished: bool = false
@export var rounds: int
@export var persistant_properties := {}

func deserialize(combat: Combat) -> CombatEvent:
	var event: CombatEvent
	if type is EnemyEventType:
		event = EnemyEvent.new()
	else:
		event = CombatEvent.new()
	event.combat = combat
	event.id = id
	event.type = type
	event.logic = type.logic.new()
	event.logic.setup(combat, event)
	event.params = params
	event.active = active
	event.finished = finished
	event.rounds = rounds
	event.persistant_properties = persistant_properties
	return event
