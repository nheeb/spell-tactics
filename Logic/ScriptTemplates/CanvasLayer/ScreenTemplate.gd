extends CanvasLayer

var activity: Activity

func set_activity(_activity: Activity) -> void:
	self.activity = _activity

func on_view_removed() -> void:
	queue_free()
