class_name LogEntry extends Resource

enum Type {
	Info,
	Incident,
	TurnTransition,
	Event,
	EnemyEvent,
	Enemy,
	EventPrognose
}

@export var type: Type
@export var round_number: int
@export var text: String
@export var spell: SpellReference
@export var number: int

static func entry_to_string(entry: LogEntry) -> String:
	var type_text : String = Type.keys()[Type.values().find(entry.type)]
	return "[%s]: %s %s" % [type_text, entry.text, \
									str(entry.number) if entry.number else ""]
