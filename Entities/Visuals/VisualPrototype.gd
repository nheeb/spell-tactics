@tool
extends VisualEntity

func _enter_tree() -> void:
	$HealthbarQuad.get_active_material(0).albedo_texture = $SubViewport.get_texture()

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
				$HPLabel.visible = false
				$HPLabel.position.y += 1.7 * type.prototype_scale.y
				$HealthbarQuad.position.y += 1.7 * type.prototype_scale.y
		else:
			$PrototypeBillboard.visible = false
			$Label.visible = true

## For overriding and making the drain effect
func visual_drain(drained := true):
	if $PrototypeBillboard.visible:
		$PrototypeBillboard.drain_transition(drained)
		
func update_hp(hp, armor, max_hp):
	$SubViewport/HealthBar2D.set_hp(hp, armor, max_hp)
