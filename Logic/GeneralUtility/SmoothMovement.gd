class_name SmoothMovement extends Node3D

@onready var parent : Node3D = get_parent() as Node3D
@onready var pos : Vector3 = parent.global_position
@onready var scale_distance : Vector3 = %ScaleOrigin.global_position - pos

var first_time := true

@export var pos_min_speed := 0.1
@export var pos_max_speed := 10.0
@export var pos_acc := 2.0
@export var pos_lerp_factor := .99
@export var pos_delta := .005 ** 2
@export var pos_damp := .75
@export var extra_damp_range := 1.5
@export var extra_damp_factor := .1

var pos_velocity := Vector3.ZERO
var target_pos := Vector3.ZERO

@export var scale_speed := 1.7

var target_scale := Vector3.ONE

@export var rotation_speed := .5
@export var rotation_custom_node: Node3D

var target_rotation := Vector3.ZERO

@export var time_scale := 3.0
## The control_value controls the strength of swinging forces
func movement_process(delta: float, control_value := 1.0):
	if first_time:
		first_time_setup()
	delta *= time_scale
	# Position
	var current_pos := pos
	if current_pos.distance_squared_to(target_pos) > pos_delta:
		var pos_direction = current_pos.direction_to(target_pos)
		var pos_distance = current_pos.distance_to(target_pos)
		
		# Accelerate & damp to position
		pos_velocity += pos_direction * pos_acc * delta * control_value
		var dynamic_damp := pos_damp * \
				Utility.clamp_map_pow(pos_distance, 0.0, extra_damp_range, extra_damp_factor, 1.0, 2.0)
		pos_velocity *= pow(dynamic_damp, delta * control_value)
		var pos_speed := pos_velocity.length()
		
		# Get lerp velocity
		var lerp_value := 1.0 - pow(1.0 - pos_lerp_factor, delta)
		var pos_lerp_velocity : Vector3 = lerp(current_pos, target_pos, \
										lerp_value) - current_pos
		var pos_lerp_speed = pos_lerp_velocity.length() / delta
		
		# Limit velocity by lerp speed and min_speed
		var optimal_speed : float = min(pos_lerp_speed, pos_speed, pos_max_speed)
		if optimal_speed < pos_min_speed:
			pos_velocity = pos_min_speed * pos_direction
		else:
			var speed_factor : float = optimal_speed / pos_speed
			pos_velocity *= speed_factor
		
		# Execute the movement
		pos += pos_velocity * delta
		
		#var dir_sign : Vector3 = sign(pos_direction)
		#var new_sign : Vector3 = sign(pos.direction_to(target_pos))
		#var compare_sign : Vector3 = sign(abs(dir_sign+new_sign) - Vector3.ONE * 2.0) # 0.0 means the value has not been crossed
		#var invert_sign : Vector3 = Vector3.ONE - compare_sign
		#pos = invert_sign * pos + compare_sign * target_pos
		#pos_velocity = invert_sign * pos_velocity
	else:
		pos_velocity = Vector3.ZERO
		pos = target_pos

	

	# Scale
	parent.scale = parent.scale.move_toward(target_scale,delta * scale_speed)
	var scale_lift : Vector3  = scale_distance - scale_distance * parent.scale
	
	# Rotation
	if rotation_custom_node == null:
		parent.rotation = parent.rotation.move_toward(target_rotation,delta * rotation_speed)
	else:
		rotation_custom_node.rotation = rotation_custom_node.rotation.move_toward(target_rotation,delta * rotation_speed)
	# Finalize Position
	if (pos + scale_lift).is_finite():
		parent.global_position = pos + scale_lift
	

func first_time_setup():
	first_time = false
	pos = parent.global_position
	scale_distance = %ScaleOrigin.global_position - pos
