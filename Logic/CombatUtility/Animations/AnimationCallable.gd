class_name AnimationCallable extends AnimationObject

var callable: Callable

func _init(_callable: Callable):
	callable = _callable

func play(level: Level) -> void:
	if is_instance_valid(callable.get_object()):
		callable.call()
	else:
		printerr("Callable has no valid object")
	animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Do a callable"
