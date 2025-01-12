class_name AnimationWait extends AnimationObject

var wait_time: float
var record_id: String

## Time to wait
func _init(time) -> void:
	wait_time = time
	_build_stack_trace()

func play():
	await VisualTime.new_timer(wait_time).timeout
	animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Wait %s" % [wait_time]

func set_record_id(_record_id) -> AnimationWait:
	if wait_time != 0.0:
		push_warning("AnimationWait with record_id will be deleted when the record is finished.")
	record_id = _record_id
	return self
