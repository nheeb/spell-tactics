extends Button

var active: Active

func _on_mouse_entered() -> void:
	Game.world.get_node("%MouseRaycast").disabled = true


func _on_mouse_exited() -> void:
	Game.world.get_node("%MouseRaycast").disabled = false
