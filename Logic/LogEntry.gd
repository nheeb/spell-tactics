class_name LogEntry extends Resource

enum Type {
	Info,
	Incident,
	TurnTransition,
	Event,
	EnemyEvent
}

@export var type: Type
@export var round_number: int
@export var text: String
@export var spell: SpellReference
