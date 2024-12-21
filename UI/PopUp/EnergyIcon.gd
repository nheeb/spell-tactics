class_name EnergyIcon extends Control

@onready var color_rect := $ColorRect
@export var min_size: int = 32:
	set(new_size):
		min_size = new_size
		if is_instance_valid(color_rect):
			color_rect.custom_minimum_size = Vector2(min_size, min_size)
			color_rect.minimum_size_changed.emit()
@export var type: EnergyStack.EnergyType = EnergyStack.EnergyType.Any:
	set(t):
		type = t
		if is_instance_valid(color_rect):
			color_rect.color = VFX.type_to_color(type)
			color_rect.material.set_shader_parameter("icon_mask", VFX.type_to_icon(type))
			color_rect.material.set_shader_parameter("icon_color", VFX.type_to_inner_color(type))

func _ready() -> void:
	# when running this scene itself, turn this into a little photo studio
	# for renders of each energy icon type
	if get_tree().current_scene == self:
		get_window().size = Vector2(128, 128)
		get_window().transparent = true
		get_window().transparent_bg = true
		for energy_type in EnergyStack.EnergyType.values():
			var type_name: String = EnergyStack.EnergyType.keys()[energy_type]
			self.type = energy_type
			await get_tree().process_frame
			await get_tree().process_frame
			var image = get_viewport().get_texture().get_image()
			image.save_png("res://Assets/Sprites/EnergyIconMasks/rendered/%s.png" % type_name.to_lower())
			await get_tree().process_frame
			await get_tree().process_frame

	color_rect.color = VFX.type_to_color(type)
	color_rect.material.set_shader_parameter("icon_mask", VFX.type_to_icon(type))
	color_rect.material.set_shader_parameter("icon_color", VFX.type_to_inner_color(type))
	color_rect.custom_minimum_size = Vector2(min_size, min_size)
