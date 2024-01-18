class_name AnimationWait extends AnimationObject

var wait_time : float

## Time to wait
func _init(time) -> void:
	wait_time = time

func play():
	await Game.tree.create_timer(wait_time).timeout
	success = true
	animation_done.emit()

func _to_string() -> String:
	return "Anim: Wait %s" % [wait_time]
