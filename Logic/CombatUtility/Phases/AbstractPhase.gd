class_name AbstractPhase extends Node

signal process_start
signal process_end

@onready var combat : Combat = get_parent().get_parent()
# TODO doesn't work since they're not initialized yet -- any way to fix this?
#@onready var level: Level = combat.level
#@onready var player: PlayerEntity = combat.player

#func tile_hovered(tile: Tile):
	#pass
	#
#func tile_clicked(tile: Tile):
	#pass
#
#func card_hovered(card: HandCard3D):
	#pass

## For overriding Processes the phase. Returns true if Player input is needed to advance to the next phase
func process_phase() -> bool:
	push_error("Abstract Phase used")
	return false

func _process_phase() -> bool:
	process_start.emit()
	var user_input = process_phase()
	process_end.emit()
	return user_input

func get_reference() -> CombatNodeReference:
	return CombatNodeReference.new(combat.get_path_to(self))
