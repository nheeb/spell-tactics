class_name AbstractPhase extends Node

signal process_start
signal process_end

@onready var combat : Combat = get_parent().get_parent()

## For overriding Processes the phase. 
func process_phase() -> void:
	push_error("Abstract Phase used")

func _process_phase() -> void:
	process_start.emit()
	await process_phase()
	process_end.emit()

## Returns true if Player input is needed to advance to the next phase
func needs_user_input_to_proceed() -> bool:
	return false

func get_reference() -> CombatNodeReference:
	return CombatNodeReference.new(combat.get_path_to(self))
