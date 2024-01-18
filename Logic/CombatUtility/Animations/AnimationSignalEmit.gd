class_name AnimationSignalEmit extends AnimationObject

var reference: Object
var signal_name: String

## Time to wait
func _init(ref: Object, s: String) -> void:
	reference = ref
	signal_name = s

func play():
	if is_instance_valid(reference):
		if reference.has_signal(signal_name):
			reference.emit_signal(signal_name)
			success = true
	animation_done.emit()

func _to_string() -> String:
	return "Anim: Signal %s on Object %s" % [signal_name, reference]
