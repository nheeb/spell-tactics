extends Node3D

var velocity := Vector3.ZERO
@export var acceleration := 30.0
@export var damping := .02

func _physics_process(delta: float) -> void:
	velocity += delta * acceleration * Vector3.RIGHT * (Input.get_action_strength("move_camera_right") - Input.get_action_strength("move_camera_left"))
	velocity += delta * acceleration * Vector3.FORWARD * (Input.get_action_strength("move_camera_forwards") - Input.get_action_strength("move_camera_backwards"))
	velocity *= pow(damping, delta)
	
	global_position += velocity * delta
