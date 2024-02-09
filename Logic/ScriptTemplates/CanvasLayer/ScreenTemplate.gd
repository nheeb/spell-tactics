extends CanvasLayer

var activity

func set_activity(_activity: Activity) -> void:
	self.activity = _activity

func on_view_removed() -> void:
	queue_free()
