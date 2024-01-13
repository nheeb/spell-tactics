class_name AbstractPhase extends Node

@onready var combat : Combat = get_parent().get_parent()

## Processes the phase. Returns true if Player input is needed to advace to the next phase
func process_phase() -> bool:
	printerr("Abstract Phase used")
	return false
