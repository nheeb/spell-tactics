extends Control


func _ready() -> void:
	if Game.DEBUG_SKIP_OVERWORLD:
		Game.view_orchestrator.transition_to_combat("res://Levels/Area1/rivers.tres")
		
	await get_tree().process_frame
	# FIXME need to put this somewhere else so it works on loading a new level!
	$PopupLayer/PopUpHandler.combat = %World.combat
