class_name AnimationCallable extends AnimationObject

var callable: Callable

func _init(_callable: Callable):
	callable = _callable

func play(level: Level) -> void:
	callable.call()
	animation_done.emit()

func _to_string() -> String:
	return "Anim: Do a callable"
