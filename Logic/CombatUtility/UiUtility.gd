class_name UiUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

func set_debug_status(message: String) -> void:
	combat.animation_queue.append(AnimationObject.new(combat.ui, "set_status", [message]))
