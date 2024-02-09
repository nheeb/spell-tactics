class_name InputUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

signal performed_action(action: PlayerAction)

## returns whether it is valid
func process_action(action: PlayerAction) -> bool:
	if action.is_valid(combat):
		print("Doing Player Action: %s" % action.action_string)
		action.execute(combat)
		performed_action.emit(action)
		combat.animation.play_animation_queue()
		return true
	else:
		# should we throw an error msg here or will this happen in normal play?
		# printerr("Invalid Player Action: %s" % action.action_string)
		action.on_fail(combat)
		return false
