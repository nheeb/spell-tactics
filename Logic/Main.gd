extends Control


func _ready() -> void:
	if Game.DEBUG_SKIP_OVERWORLD:
		Game.view_orchestrator.transition_to_combat("res://Levels/Area1/rivers.tres")
