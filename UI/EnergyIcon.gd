@tool
class_name EnergyIcon extends Control

@onready var color_rect := $ColorRect
@export var min_size: int = 32:
	set(new_size):
		min_size = new_size
		if is_instance_valid(color_rect):
			color_rect.custom_minimum_size = Vector2(min_size, min_size)
@export var type: EnergyStack.EnergyType = EnergyStack.EnergyType.Any:
	set(t):
		type = t
		if is_instance_valid(color_rect):
			color_rect.color = type_to_color(type)


@export var any_color: Color
@export var matter_color: Color
@export var life_color: Color
@export var harmony_color: Color
@export var flow_color: Color
@export var decay_color: Color
@export var spectral_color: Color
func type_to_color(_type) -> Color:
	match _type:
		EnergyStack.EnergyType.Any:
			return any_color
		EnergyStack.EnergyType.Matter:
			return matter_color
		EnergyStack.EnergyType.Life:
			return life_color
		EnergyStack.EnergyType.Harmony:
			return harmony_color
		EnergyStack.EnergyType.Flow:
			return flow_color
		EnergyStack.EnergyType.Decay:
			return decay_color
		EnergyStack.EnergyType.Spectral:
			return spectral_color
	printerr("unknown type")
	return Color.RED

@export var icons: Array[Texture]
func type_to_icon(_type) -> Texture:
	match _type:
		EnergyStack.EnergyType.Any:
			return icons[0]
		EnergyStack.EnergyType.Matter:
			return icons[1]
		EnergyStack.EnergyType.Life:
			return icons[2]
		EnergyStack.EnergyType.Harmony:
			return icons[3]
		EnergyStack.EnergyType.Flow:
			return icons[4]
		EnergyStack.EnergyType.Decay:
			return icons[5]
		EnergyStack.EnergyType.Spectral:
			return icons[6]
	printerr("unknown type")
	return icons[0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.color = type_to_color(type)
	color_rect.custom_minimum_size = Vector2(min_size, min_size)
