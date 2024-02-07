extends Control

func _on_continue_pressed():
	Game.view_orchestrator.transition_to_overworld()


func _on_review_pressed() -> void:
	Game.view_orchestrator.transition_to_combat_review()
