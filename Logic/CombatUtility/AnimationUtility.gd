class_name AnimationUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

signal animation_queue_empty

func play_animation_queue():
	while not combat.animation_queue.is_empty():
		var animation_object : AnimationObject = combat.animation_queue.pop_front()
		animation_object.play()
		await animation_object.animation_done
	animation_queue_empty.emit()
