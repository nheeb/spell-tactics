class_name Card3D extends Node3D

@onready var smooth_movement: SmoothMovement = $SmoothMovement

func get_empty_energy_socket(type : EnergyStack.EnergyType) -> HandCardEnergySocket:
	return null

func get_castable() -> Castable:
	return null

func set_pinned(s: bool):
	pass
