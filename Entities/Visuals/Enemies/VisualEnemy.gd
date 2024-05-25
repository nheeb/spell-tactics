class_name VisualEnemy extends VisualEntity


func _enter_tree() -> void:
	$HealthbarQuad.get_active_material(0).albedo_texture = $SubViewport.get_texture()


func update_hp(hp, armor, max_hp):
	$SubViewport/HealthBar2D.set_hp(hp, armor, max_hp)
