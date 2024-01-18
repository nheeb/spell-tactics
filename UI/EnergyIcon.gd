#@tool
extends Control

@onready var color_rect := $ColorRect

@export var type: Game.Energy = Game.Energy.Any:
	set(t):
		type = t
		if is_instance_valid(color_rect):
			match type:
				Game.Energy.Any:
					color_rect.color = Color.WHITE_SMOKE
				Game.Energy.Matter:
					color_rect.color = Color.DARK_GOLDENROD
				Game.Energy.Life:
					color_rect.color = Color.GREEN_YELLOW
				Game.Energy.Water:
					color_rect.color = Color.AQUA
				Game.Energy.Flow:
					color_rect.color = Color.CORAL
				Game.Energy.Decay:
					color_rect.color = Color.MEDIUM_PURPLE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	match type:
		Game.Energy.Any:
			color_rect.color = Color.WHITE_SMOKE
		Game.Energy.Matter:
			color_rect.color = Color.DIM_GRAY
		Game.Energy.Water:
			color_rect.color = Color.AQUA
		Game.Energy.Flow:
			color_rect.color = Color.CORAL
		Game.Energy.Decay:
			color_rect.color = Color.MEDIUM_PURPLE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
