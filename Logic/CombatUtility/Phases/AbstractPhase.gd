class_name AbstractPhase extends Node

@onready var combat : Combat = get_parent().get_parent()
# TODO doesn't work since they're not initialized yet -- any way to fix this?
#@onready var level: Level = combat.level
#@onready var player: PlayerEntity = combat.player


func tile_hovered(tile: Tile):
	pass
	
func tile_clicked(tile: Tile):
	pass

## For overriding Processes the phase. Returns true if Player input is needed to advance to the next phase
func process_phase() -> bool:
	printerr("Abstract Phase used")
	return false

func _process_phase() -> bool:
	var timed_effects := combat.timed_effects.duplicate()
	for timed_effect in timed_effects:
		timed_effect = timed_effect as TimedEffect
		if timed_effect.phase == combat.current_phase:
			timed_effect.advance(combat)
		# combat.timed_effects.erase(timed_effect) this will be done by the TimedEffect base class
	return process_phase()

