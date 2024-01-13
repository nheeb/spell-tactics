class_name AnimationObject extends Object

signal animation_done

var reference: Object
var command: String
var parameters: Array
var flags: int

func _init(_reference: Object, _command: String, _parameters := [], _flags: int = 0):
	reference = _reference
	command = _command
	parameters = _parameters
	flags = _flags

func play() -> void:
	if reference != null:
		reference.callv(command, parameters)
		if reference.has_signal("animation_done"):
			await reference.animation_done
	else:
		printerr("Animation on null reference")
	await Game.tree.process_frame
	animation_done.emit()
