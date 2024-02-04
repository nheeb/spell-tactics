extends Control

func _on_continue_pressed():
	# TODO - change to transition back to main menu.
	Game.view_orchestrator.transition_to_overworld()
