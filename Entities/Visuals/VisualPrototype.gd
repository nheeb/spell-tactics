@tool
extends VisualEntity

func _ready() -> void:
	if is_instance_valid($Label) and is_instance_valid(type):
		$Label.text = type.internal_name
		if PrototypeBillboard.has_billboard_texture(type.internal_name):
			$PrototypeBillboard.set_texture_from_entity_name(type.internal_name)
			$Label.position.y += 1.7
			$PrototypeBillboard.visible = true
		else:
			$PrototypeBillboard.visible = false
