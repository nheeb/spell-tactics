class_name ActiveCard extends Card3D

func _enter_tree() -> void:
	%Cube.material_override.next_pass.set("shader_parameter/random_seed", randf())
	%Cube.material_override.next_pass.set("shader_parameter/card_texture", $TextureViewport.get_texture())
	%Cube.material_override.uv1_offset = Vector3(randf(), randf(), 0) * 10.0

func set_render_prio(p: int) -> void:
	%Cube.material_override.set("render_priority", p)
	%Cube.material_override.next_pass.set("render_priority", p+1)

func set_collision_scale(s: float) -> void:
	$Area3D/CollisionShape3D.scale = Vector3.ONE * s

var active: Active

func set_active(_active: Active):
	active = _active
	active.card = self
	# Set Texture
	%HandCardTexture.set_castable(active)
	# Set Shader color
	%Cube.material_override.next_pass.set("shader_parameter/albedo", active.type.color)

func get_active() -> Active:
	return active

func get_castable() -> Castable:
	return get_active()
