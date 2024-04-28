class_name OrbitalMovementBody extends Node3D

static var BASE_RADUIS := 1.2
static var ROUNDS_PER_SECOND := .4
static var TILT_ROUNDS_PER_SECOND := .2
static var TILT_ANGLE := PI / 8.0

var orbits: Array[Orbit] = []

class Orbit:
	var radius : float = OrbitalMovementBody.BASE_RADUIS
	var rounds_per_second : float = OrbitalMovementBody.ROUNDS_PER_SECOND
	var tilt_angle : float = OrbitalMovementBody.TILT_ANGLE
	var tilt_rounds_per_second := OrbitalMovementBody.TILT_ROUNDS_PER_SECOND
	var base_up_vector := Vector3.UP
	var tilted_up_vector : Vector3
	var body: OrbitalMovementBody
	var movements : Array[OrbitalMovement] = []
	func _init(_body: OrbitalMovementBody, tilt_direction: Vector3) -> void:
		body = _body
		var tilt_rotation_axis := base_up_vector.cross(tilt_direction)
		tilted_up_vector = base_up_vector.rotated(tilt_rotation_axis, tilt_angle)
	func movement_process(delta: float) -> void:
		tilted_up_vector = tilted_up_vector.rotated(base_up_vector, \
							TAU * delta * tilt_rounds_per_second)
	func get_nearest_point(pos: Vector3) -> Vector3:
		var dir := body.global_position.direction_to(pos)
		var projected_dir := dir - dir.project(tilted_up_vector)
		return body.global_position + projected_dir * radius
	func get_orbital_move(om: OrbitalMovement, delta: float) -> Vector3:
		if om in movements:
			var point := get_nearest_point(om.global_position)
			var rotated := point.rotated(tilted_up_vector, rounds_per_second * delta * TAU)
			return rotated - point
		else:
			return Vector3.ZERO

func attach_movement(om: OrbitalMovement) -> void:
	# For now we only use one orbit
	# TODO nitai add multiple orbits
	if orbits.is_empty():
		orbits.append(Orbit.new(self, Vector3.FORWARD))
	if not om in orbits[0].movements:
		orbits[0].movements.append(om)

func detach_movement(om: OrbitalMovement) -> void:
	if not orbits.is_empty():
		orbits[0].movements.erase(om)

func get_orbital_move(om: OrbitalMovement, delta: float) -> Vector3:
	return Utility.array_sum(orbits.map(func (orbit): \
							return orbit.get_orbital_move(om, delta)))

#@export var tilt_max_angle := PI / 8.0
#@export var tilt_factor := 1.0
#@export var tilt_rounds_per_second := .1
#
#@export var base_up_vector := Vector3.UP
#@export var base_tilt_rotation_vector := Vector3.FORWARD
#
#@export var offset := Vector3(0.0, 1.0, 0.0)
#
#var tilt_turn_angle := 0.0
#var pivot_turn_angle := 0.0
#
#func movement_process(delta: float) -> void:
	#tilt_turn_angle += tilt_rounds_per_second * delta * TAU
	#pivot_turn_angle += rounds_per_second * delta * TAU
	#tilt_turn_angle = fposmod(tilt_turn_angle, TAU)
	#pivot_turn_angle = fposmod(pivot_turn_angle, TAU)
	#
	#var tilt_actual_angle := tilt_max_angle * tilt_factor
	#var tilt_vector := base_up_vector.rotated(base_tilt_rotation_vector, tilt_actual_angle) \
						#.rotated(base_up_vector, tilt_actual_angle)
	#var pivot_vector := tilt_vector.cross(base_tilt_rotation_vector) \
						#.rotated(tilt_vector, pivot_turn_angle) * radius
	#
	#var movement_count := len(movements)
	#var angle_dist := TAU / movement_count
	#
	#for i in range(movement_count):
		#var target_pos = pivot_vector.rotated(tilt_vector, i * angle_dist)
		#movements[i].orbit_target_pos = global_position + offset + target_pos
