@tool
extends VisualEntity


func _ready() -> void:
	if is_instance_valid($Label) and is_instance_valid(type):
		$Label.text = type.internal_name
		if PrototypeBillboard.has_billboard_texture(type.internal_name):
			$PrototypeBillboard.set_texture_from_entity_name(type.internal_name)
			$PrototypeBillboard.scale.x = type.prototype_scale.x
			$PrototypeBillboard.scale.y = type.prototype_scale.y
			$Label.visible = false
			$PrototypeBillboard.visible = true
			if type is HPEntityType:
				$HealthBar3D.visible = true
				$HealthBar3D.position.y += 2.00 * type.prototype_scale.y
		else:
			$PrototypeBillboard.visible = false
			$Label.visible = true

## For overriding and making the drain effect
func visual_drain(drained := true):
	if $PrototypeBillboard.visible:
		$PrototypeBillboard.drain_transition(drained)
		
		

