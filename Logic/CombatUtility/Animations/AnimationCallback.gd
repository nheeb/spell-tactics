class_name AnimationCallback extends AnimationObject

var reference: Object
var command: String
var parameters: Array

func _init(_reference: Object, _command: String, _parameters := []):
	reference = _reference
	command = _command
	parameters = _parameters

func play(level: Level) -> void:
	if is_instance_valid(reference):
		reference.callv(command, parameters)
		if reference.has_signal("animation_done"):
			print("Waiting for %s to send a signal" % reference.name)
			await reference.animation_done
		success = true
	else:
		printerr("Animation on null reference")
	animation_done.emit()

func _to_string() -> String:
	if len(parameters) == 1:
		return "Anim: Calling %s.%s(%s)" % [reference.name, command, parameters[0]]
	else:
		return "Anim: %s calls %s(%s)" % [reference.name, command, parameters]
