extends VisualEntity

func _ready() -> void:
	if is_instance_valid($Label) and is_instance_valid(type):
		$Label.text = type.internal_name
