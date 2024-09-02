class_name LogEntry extends Resource

enum Type {
	Info, # Just text as info for debugging
	Incident,
	TurnTransition,
	Event,
	EnemyEvent,
	Enemy,
	EventPrognose, # TODO Delete this
	Cast,
	Damage,
}

@export var type: Type
@export var round_number: int
@export var round_phase: int # TODO implement this
@export var text: String
@export var spell: SpellReference
@export var uni_ref: UniversalReference
@export var number: int

func _init(combat: Combat = null) -> void:
	if combat:
		if combat.action_stack.active_ticket:
			combat.action_stack.active_ticket.log_entries.append(self)

func get_action_ticket(combat: Combat) -> ActionTicket:
	return combat.action_stack._stack.filter(
		func (ticket: ActionTicket):
			return self in ticket.log_entries
	).front()

static func entry_to_string(entry: LogEntry) -> String:
	var type_text : String = Type.keys()[Type.values().find(entry.type)]
	return "[%s]: %s %s" % [type_text, entry.text, \
									str(entry.number) if entry.number else ""]
