class_name AnimationWaitForSignal extends AnimationObject

var obj : Object
var signal_name : String

## Time to wait
func _init(_obj: Object, _signal_name: String) -> void:
	obj = _obj
	signal_name = _signal_name

func play(level: Level):
	if obj.has_signal(signal_name):
		await obj.get(signal_name)
	else:
		printerr("Anim: WaitforSignal Signal does not exist")
	animation_done.emit()

func _to_string() -> String:
	return "Anim: Wait for %s.%s" % [obj, signal_name]