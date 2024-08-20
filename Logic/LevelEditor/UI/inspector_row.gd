extends HBoxContainer


static var translate_blocker: Utils.Blocker = GameCamera.translate_block.register_blocker()


func _on_value_focus_entered() -> void:
	translate_blocker.block()


func _on_value_focus_exited() -> void:
	translate_blocker.unblock()
