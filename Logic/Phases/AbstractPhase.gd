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
	for timed_effect in combat.timed_effects.duplicate():
		timed_effect = timed_effect as TimedEffect
		if timed_effect.phase == combat.current_phase:
			timed_effect.advance(combat)
	return process_phase()

