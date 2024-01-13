class_name AnimationObject extends Node

signal animation_done

var reference: Object
var command: String
var parameters: Array

func _init(_reference: Object, _command: String, _parameters := []):
	reference = _reference
	command = _command

func play() -> void:
	if reference != null:
		reference.callv(command, parameters)
		if reference.has_signal("animation_done"):
			await reference.animation_done
	else:
		printerr("Animation on null reference")
	await get_tree().process_frame
	animation_done.emit()
