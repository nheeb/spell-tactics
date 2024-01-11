extends Node3D

var velocity := Vector3.ZERO
var rotation_input := 0.0
@export var move_acceleration := 30.0
## 45 degrees per second
@export var rotation_velocity := 100.0
@export var damping := .02
@export var rot_damping := 0.02

func _physics_process(delta: float) -> void:
	# x-z movement
	velocity += delta * move_acceleration * (basis * Vector3.RIGHT) * (Input.get_action_strength("move_camera_right") - Input.get_action_strength("move_camera_left"))
	velocity += delta * move_acceleration * (basis * Vector3.FORWARD) * (Input.get_action_strength("move_camera_forwards") - Input.get_action_strength("move_camera_backwards"))
	velocity *= pow(damping, delta)
	global_position += velocity * delta
		
	# rotation
	rotation_input = delta * rotation_velocity * (Input.get_action_strength("rotate_camera_clockwise") - Input.get_action_strength("rotate_camera_anticlockwise"))
	rotate_y(deg_to_rad(rotation_input))
