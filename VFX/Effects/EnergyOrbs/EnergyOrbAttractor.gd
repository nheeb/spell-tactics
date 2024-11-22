class_name EnergyOrbAttractor extends Node3D

@onready var origin : Node3D = $Origin
@onready var destination : Node3D = $Destination

func get_pos(progress: float) -> Vector3:
	return lerp(origin.global_position, destination.global_position, progress)

func get_dir() -> Vector3:
	return origin.global_position.direction_to(destination.global_position)
