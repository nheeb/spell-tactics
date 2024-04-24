class_name OrbitalMovementBody extends Node3D

var movements : Array[OrbitalMovement] = []

@export var radius := 1.2
@export var rounds_per_second := .4

@export var tilt_max_angle := PI / 8.0
@export var tilt_factor := 1.0
@export var tilt_rounds_per_second := .1

@export var base_up_vector := Vector3.UP
@export var base_tilt_rotation_vector := Vector3.FORWARD

@export var offset := Vector3(0.0, 1.0, 0.0)

var tilt_turn_angle := 0.0
var pivot_turn_angle := 0.0

func movement_process(delta: float) -> void:
	tilt_turn_angle += tilt_rounds_per_second * delta * TAU
	pivot_turn_angle += rounds_per_second * delta * TAU
	tilt_turn_angle = fposmod(tilt_turn_angle, TAU)
	pivot_turn_angle = fposmod(pivot_turn_angle, TAU)
	
	var tilt_actual_angle := tilt_max_angle * tilt_factor
	var tilt_vector := base_up_vector.rotated(base_tilt_rotation_vector, tilt_actual_angle) \
						.rotated(base_up_vector, tilt_actual_angle)
	var pivot_vector := tilt_vector.cross(base_tilt_rotation_vector) \
						.rotated(tilt_vector, pivot_turn_angle) * radius
	
	var movement_count := len(movements)
	var angle_dist := TAU / movement_count
	
	for i in range(movement_count):
		var target_pos = pivot_vector.rotated(tilt_vector, i * angle_dist)
		movements[i].orbit_target_pos = global_position + offset + target_pos
