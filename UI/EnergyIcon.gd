@tool
class_name EnergyIcon extends Control

@onready var color_rect := $ColorRect
@export var min_size: int = 24:
	set(new_size):
		min_size = new_size
		if is_instance_valid(color_rect):
			color_rect.custom_minimum_size = Vector2(min_size, min_size)
@export var type: EnergyStack.EnergyType = EnergyStack.EnergyType.Any:
	set(t):
		type = t
		if is_instance_valid(color_rect):
			match type:
				EnergyStack.EnergyType.Any:
					color_rect.color = Color.WHITE_SMOKE
				EnergyStack.EnergyType.Matter:
					color_rect.color = Color.DIM_GRAY
				EnergyStack.EnergyType.Life:
					color_rect.color = Color.GREEN_YELLOW
				EnergyStack.EnergyType.Harmony:
					color_rect.color = Color.AQUA
				EnergyStack.EnergyType.Flow:
					color_rect.color = Color.CORAL
				EnergyStack.EnergyType.Decay:
					color_rect.color = Color.MEDIUM_PURPLE
				EnergyStack.EnergyType.Spectral:
					color_rect.color = Color.HOT_PINK


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match type:
		EnergyStack.EnergyType.Any:
			color_rect.color = Color.WHITE_SMOKE
		EnergyStack.EnergyType.Matter:
			color_rect.color = Color.DIM_GRAY
		EnergyStack.EnergyType.Life:
			color_rect.color = Color.GREEN_YELLOW
		EnergyStack.EnergyType.Harmony:
			color_rect.color = Color.AQUA
		EnergyStack.EnergyType.Flow:
			color_rect.color = Color.CORAL
		EnergyStack.EnergyType.Decay:
			color_rect.color = Color.MEDIUM_PURPLE
		EnergyStack.EnergyType.Spectral:
			color_rect.color = Color.HOT_PINK
	color_rect.custom_minimum_size = Vector2(min_size, min_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
