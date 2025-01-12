class_name AnimationSignalEmit extends AnimationObject

var object: Object
var signal_name: String

## Time to wait
func _init(ref: Object, s: String) -> void:
	object = ref
	signal_name = s

func play():
	if is_instance_valid(object):
		if object.has_signal(signal_name):
			object.emit_signal(signal_name)
	animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Signal %s.%s.emit()" % [object, signal_name]
