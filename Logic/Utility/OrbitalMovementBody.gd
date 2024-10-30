class_name OrbitalMovementBody extends Node3D

static var BASE_RADUIS := .7
static var ROUNDS_PER_SECOND := .25
static var TILT_ROUNDS_PER_SECOND := .15
static var TILT_ANGLE := PI / 12.0
static var CORRECTION_RPS := .5
static var BOUND_LERP := .05

var orbits: Array[Orbit] = []

@export var use_global_up_vector := false
@export var radius_scale := 1.0
@export var speed_scale := 1.0

class Orbit:
	var radius : float = OrbitalMovementBody.BASE_RADUIS
	var rounds_per_second : float = OrbitalMovementBody.ROUNDS_PER_SECOND
	var tilt_angle : float = OrbitalMovementBody.TILT_ANGLE
	var tilt_rounds_per_second := OrbitalMovementBody.TILT_ROUNDS_PER_SECOND
	var base_up_vector := Vector3.UP
	var tilt_direction : Vector3
	var tilted_up_vector : Vector3
	var body: OrbitalMovementBody
	var movements : Array[OrbitalMovement] = []
	var movements_angle_dist : Array[float] = []
	var movements_target_points : Dictionary = {} # Movement -> Target Point (Vec3)
	func _init(_body: OrbitalMovementBody, _tilt_direction: Vector3) -> void:
		body = _body
		tilt_direction = _tilt_direction
		if body.use_global_up_vector:
			base_up_vector = body.get_global_y_direction()
		rounds_per_second *= body.speed_scale
		tilt_rounds_per_second *= body.speed_scale
		radius *= body.radius_scale
		var tilt_rotation_axis := base_up_vector.cross(tilt_direction).normalized()
		tilted_up_vector = base_up_vector.rotated(tilt_rotation_axis, tilt_angle)
	func movement_process(delta: float) -> void:
		# Rotate Tilt
		tilted_up_vector = tilted_up_vector.rotated(base_up_vector, \
							TAU * delta * tilt_rounds_per_second)
		# Calculate Angle Dist
		reorder_movements_and_calculate_angle_dist()
	func reorder_movements_and_calculate_angle_dist():
		movements_target_points.clear()
		for movement in movements:
			movements_target_points[movement] = get_nearest_point(movement.global_position)
		movements.sort_custom(
			func(a,b):
				var angle_a = (movements_target_points[a] - body.global_position)\
								.signed_angle_to(tilt_direction, base_up_vector)
				var angle_b = (movements_target_points[b] - body.global_position)\
								.signed_angle_to(tilt_direction, base_up_vector)
				return angle_a < angle_b
		)
		movements_angle_dist.clear()
		for i in range(movements.size()):
			var movement_a := movements[i-1]
			var movement_b := movements[i]
			var point_a = movements_target_points[movement_a] - body.global_position
			var point_b = movements_target_points[movement_b] - body.global_position
			var angle : float = Utility.positive_angle(
				-point_a.signed_angle_to(point_b, tilted_up_vector)
			)
			if is_nan(angle):
				angle = 0.0
			movements_angle_dist.append(angle)
		if Input.is_action_just_pressed("test_u"):
			print(movements_angle_dist)
	func get_nearest_point(pos: Vector3) -> Vector3:
		var dir := body.global_position.direction_to(pos)
		var projected_dir := dir - dir.project(tilted_up_vector)
		return body.global_position + projected_dir * radius
	func get_orbital_move(om: OrbitalMovement, delta: float) -> Vector3:
		if not om in movements:
			return Vector3.ZERO
		var point := get_nearest_point(om.global_position) - body.global_position
		# FIXME E 0:11:05:0482   OrbitalMovementBody.gd:78 @ get_orbital_move(): The axis Vector3 (-0.253956, 0.643611, 0.722749) must be normalized.
#  <C++ Error>    Condition "!p_axis.is_normalized()" is true.
#  <C++ Source>   core/math/basis.cpp:852 @ set_axis_angle()
#  <Stack Trace>  OrbitalMovementBody.gd:78 @ get_orbital_move() "-> 89"
#                 OrbitalMovementBody.gd:118 @ <anonymous lambda>()
#                 OrbitalMovementBody.gd:117 @ get_orbital_move()
#                 OrbitalMovement.gd:100 @ _get_move()
#                 OrbitalMovement.gd:55 @ get_move()
#                 OrbitalMovement.gd:250 @ movement_process()
#                 EnergyOrb.gd:46 @ _process()
		# this occurs for the following line
		# when having the game running for a longer time (numerical issue?)
		var rotated := point.rotated(tilted_up_vector, rounds_per_second * delta * TAU)
		return rotated - point
	func get_bound_move(om: OrbitalMovement, delta: float) -> Vector3:
		if not om in movements:
			return Vector3.ZERO
		var point := get_nearest_point(om.global_position)
		var lerped = lerp(om.global_position, point, \
						1.0 - pow(OrbitalMovementBody.BOUND_LERP, delta))
		return lerped - om.global_position
	func get_correction_move(om: OrbitalMovement, delta: float) -> Vector3:
		if not om in movements:
			return Vector3.ZERO
		var dist_a = Utility.array_safe_get(movements_angle_dist, movements.find(om), true)
		var dist_b = Utility.array_safe_get(movements_angle_dist, movements.find(om) + 1, true)
		var turn := 0.0
		if (dist_a + dist_b) > 0.0:
			var v : float = dist_a / (dist_a + dist_b)
			turn = Utility.clamp_map(v, 0, 1, -1, 1)
		var point := get_nearest_point(om.global_position) - body.global_position
		var correction := point.rotated(tilted_up_vector, \
							OrbitalMovementBody.CORRECTION_RPS * turn * delta)
		return correction - point

func attach_movement(om: OrbitalMovement) -> void:
	# For now we only use one orbit
	# TODO nitai add multiple orbits
	if orbits.is_empty():
		var tilt_direction := Vector3.FORWARD
		if use_global_up_vector:
			tilt_direction = to_global(tilt_direction).normalized()
		orbits.append(Orbit.new(self,tilt_direction))
	if not om in orbits[0].movements:
		orbits[0].movements.append(om)

func detach_movement(om: OrbitalMovement) -> void:
	if not orbits.is_empty():
		orbits[0].movements.erase(om)

func get_orbital_move(om: OrbitalMovement, delta: float) -> Vector3:
	return Utility.array_sum(orbits.map(func (orbit): \
							return orbit.get_orbital_move(om, delta)))

func get_bound_move(om: OrbitalMovement, delta: float) -> Vector3:
	return Utility.array_sum(orbits.map(func (orbit): \
							return orbit.get_bound_move(om, delta)))

func get_correction_move(om: OrbitalMovement, delta: float) -> Vector3:
	return Utility.array_sum(orbits.map(func (orbit): \
							return orbit.get_correction_move(om, delta)))

func get_orbit_dist(om: OrbitalMovement) -> float:
	var dist := om.global_position.distance_to(self.global_position)
	return Utility.array_average(orbits.filter(
		func (orbit: Orbit):
			return om in orbit.movements
	).map(
		func (orbit: Orbit):
			return abs(dist - orbit.radius)
	))

static var APPROACHING_RADIUS_INNER := 1.5
static var APPROACHING_RADIUS_OUTER := 3.0
func get_orbit_approaching_progress(om: OrbitalMovement) -> float:
	return Utility.clamp_map(om.global_position.distance_to(global_position), \
							APPROACHING_RADIUS_INNER, APPROACHING_RADIUS_OUTER, 1.0, 0.0)

func movement_process(delta: float) -> void:
	for orbit in orbits:
		orbit.movement_process(delta)

func _process(delta: float) -> void:
	movement_process(VisualTime.visual_time_scale * delta)

func get_global_y_direction() -> Vector3:
	var dir : Vector3 = to_global(Vector3.ZERO).direction_to(to_global(Vector3.UP))
	return dir
