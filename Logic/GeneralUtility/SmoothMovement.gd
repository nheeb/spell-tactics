class_name SmoothMovement extends Node3D

@onready var parent : Node3D = get_parent() as Node3D

@export var pos_min_speed := 0.05
@export var pos_max_speed := 3.0
@export var pos_acc := 1.0
@export var pos_lerp_factor := .9
@export var pos_delta := .01 ** 2

var pos_velocity := Vector3.ZERO
var target_pos := Vector3.ZERO

@export var scale_speed := 3.0

var target_scale := Vector3.ONE

func movement_process(delta: float):
	# Position
	var current_pos := parent.global_position
	if current_pos.distance_squared_to(target_pos) > pos_delta:
		var pos_direction = current_pos.direction_to(target_pos)
		var pos_distance = current_pos.distance_to(target_pos)
		
		# Accelerate to position
		pos_velocity += pos_direction * pos_acc * delta
		var pos_speed := pos_velocity.length()
		
		# Get lerp velocity
		var pos_lerp_velocity : Vector3 = lerp(current_pos, target_pos, \
										pow(pos_lerp_factor, delta)) - current_pos
		var pos_lerp_speed = pos_lerp_velocity.length()
		
		# Limit velocity by lerp speed and min_speed
		pos_velocity *= max(pos_min_speed, min(pos_lerp_speed, pos_speed, pos_max_speed))\
																	/ pos_speed
		
		# Execute the movement
		parent.global_position += pos_velocity * delta
	else:
		pos_velocity = Vector3.ZERO

	#Scale
	parent.scale = parent.scale.move_toward(target_scale,delta * scale_speed)
