class_name LogEntry extends Resource

enum Type {
	Info, # Just text as info for debugging
	Action, # When an action is not finished (don't know if we'll log that ever)
	ActionFinished, # When an action gets finished
	ActionAborted, # When an action gets aborted
	TurnTransition, # When the game enters a new phase
}

@export var type: Type
@export var round_number: int
@export var round_phase: int
@export var text: String
@export var flavor: ActionFlavor

func _init(_text := "", _type: Type = Type.Info) -> void:
	text = _text
	type = _type

static func entry_to_string(entry: LogEntry) -> String:
	var type_text : String = Type.keys()[Type.values().find(entry.type)]
	return "%s.%s [%s] %s" % [type_text, entry.text]

func _to_string() -> String:
	return entry_to_string(self)
