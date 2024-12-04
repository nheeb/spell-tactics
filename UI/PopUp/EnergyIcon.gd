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
			color_rect.material.set_shader_parameter("icon_color", type_to_icon_color(type))

@export var icons: Array[Texture]
@export var icon_colors: Array[Color]
func type_to_icon(_type) -> Texture:
	match _type:
		EnergyStack.EnergyType.Any:
			return icons[0]
		EnergyStack.EnergyType.Matter:
			return icons[1]
		EnergyStack.EnergyType.Empty:
			return icons[2]
		EnergyStack.EnergyType.Harmony:
			return icons[3]
		EnergyStack.EnergyType.Flow:
			return icons[4]
		EnergyStack.EnergyType.Decay:
			return icons[5]
		EnergyStack.EnergyType.Spectral:
			return icons[6]
	push_error("unknown type")
	return icons[0]
	
func type_to_icon_color(_type) -> Color:
	match _type:
		EnergyStack.EnergyType.Any:
			return icon_colors[0]
		EnergyStack.EnergyType.Matter:
			return icon_colors[1]
		EnergyStack.EnergyType.Empty:
			return icon_colors[2]
		EnergyStack.EnergyType.Harmony:
			return icon_colors[3]
		EnergyStack.EnergyType.Flow:
			return icon_colors[4]
		EnergyStack.EnergyType.Decay:
			return icon_colors[5]
		EnergyStack.EnergyType.Spectral:
			return icon_colors[6]
	push_error("unknown type")
	return icon_colors[0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.color = VFX.type_to_color(type)
	color_rect.material.set_shader_parameter("icon_mask", type_to_icon(type))
	color_rect.material.set_shader_parameter("icon_color", type_to_icon_color(type))
	color_rect.custom_minimum_size = Vector2(min_size, min_size)
