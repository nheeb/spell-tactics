class_name LogEntry extends Resource

enum Type {
	Info,
	Incident
}

@export var type: Type
@export var round_number: int
@export var text: String
