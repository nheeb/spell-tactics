class_name OneshotVisualEffect extends Node3D

## This is just the abstract class for Oneshot Vis Effects

signal effect_done

func effect_start() -> void:
	push_error("Not implemented")
	effect_done.emit()
	queue_free()
