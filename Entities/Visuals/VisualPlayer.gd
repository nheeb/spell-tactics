class_name VisualPlayer extends VisualEntity

func _ready() -> void:
	pass

func update_hp(hp: int):
	$HPLabel.text = "%d / %d" % [hp, type.max_hp]
