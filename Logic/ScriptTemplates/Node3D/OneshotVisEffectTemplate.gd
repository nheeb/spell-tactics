extends OneshotVisualEffect

func effect_start() -> void:
	# Effect Animation goes here
	effect_done.emit()
	queue_free()
