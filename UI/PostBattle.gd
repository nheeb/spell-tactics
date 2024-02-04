extends Control

func _on_continue_pressed():
	Game.view_orchestrator.transition_to_overworld()
