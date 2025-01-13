class_name AnimationSubQueue extends AnimationObject

var animation_objects: Array[AnimationObject]

## Time to wait
func _init(_animation_objects) -> void:
	animation_objects.append_array(_animation_objects)

func play():
	var queue := AnimationQueue.new(combat, "subq", animation_objects)
	queue.play()
	await queue.queue_finished
	animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: SubQueue"
