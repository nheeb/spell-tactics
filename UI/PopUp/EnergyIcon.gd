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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.color = VFX.type_to_color(type)
	color_rect.material.set_shader_parameter("icon_mask", VFX.type_to_icon(type))
	color_rect.material.set_shader_parameter("icon_color", VFX.type_to_inner_color(type))
	color_rect.custom_minimum_size = Vector2(min_size, min_size)
