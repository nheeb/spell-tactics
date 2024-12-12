extends StayingVisualEffect

# signal effect_done should be emmited when the effect init animation is done
# signal effect_died should be emmited when the effect death animation is done

func effect_start() -> void:
	# init animation here
	effect_done.emit()

func on_effect_end() -> void:
	# death animation here
	effect_died.emit()
	queue_free()
