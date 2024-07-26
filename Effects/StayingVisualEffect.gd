class_name StayingVisualEffect extends Node3D

signal effect_done # Should be emmited when the effect init animation is done
signal effect_died # Should be emmited when the effect death animation is done

func effect_start() -> void:
	push_error("Not implemented")
	effect_done.emit()

func on_effect_end() -> void:
	push_error("Not implemented")
	effect_died.emit()
	queue_free()
