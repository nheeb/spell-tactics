class_name AnimationWait extends AnimationObject

var wait_time : float

## Time to wait
func _init(time) -> void:
	wait_time = time
	_build_stack_trace()

func play(level: Level):
	await VisualTime.new_timer(wait_time).timeout
	animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Wait %s" % [wait_time]
