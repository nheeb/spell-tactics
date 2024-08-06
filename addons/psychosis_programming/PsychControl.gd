
extends Control

func _ready() -> void:
	for c in get_parent().get_children():
		if "EditorRunBar" in str(c):
			c.visible = false
