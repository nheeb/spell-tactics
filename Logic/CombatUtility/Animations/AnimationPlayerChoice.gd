extends AnimationObject

## Time to wait
func _init(time) -> void:
	pass

func play(level: Level):
	animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Player Choice"
