class_name AnimationWait extends AnimationObject

var wait_time : float

## Time to wait
func _init(time) -> void:
	wait_time = time

func play():
	await Game.tree.create_timer(wait_time)
	animation_done.emit()
