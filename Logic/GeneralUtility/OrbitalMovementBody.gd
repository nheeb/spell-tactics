class_name OrbitalMovementBody extends Node3D

static var BASE_RADUIS := .8
static var ROUNDS_PER_SECOND := .4
static var TILT_ROUNDS_PER_SECOND := .15
static var TILT_ANGLE := PI / 12.0
static var CORRECTION_RPS := 1.0
static var BOUND_LERP := .05

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
	var movements_angle_dist : Array[float] = []
	var movements_target_points : Dictionary = {} # Movement -> Target Point (Vec3)
	func _init(_body: OrbitalMovementBody, tilt_direction: Vector3) -> void:
		body = _body
		var tilt_rotation_axis := base_up_vector.cross(tilt_direction)
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
				return movements_target_points[a].signed_angle_to(Vector3.FORWARD, Vector3.UP) \
						< movements_target_points[b].signed_angle_to(Vector3.FORWARD, Vector3.UP)
		)
		movements_angle_dist.clear()
		for i in range(movements.size()):
			var movement_a := movements[i-1]
			var movement_b := movements[i]
			var point_a = movements_target_points[movement_a]
			var point_b = movements_target_points[movement_b]
			movements_angle_dist.append(point_a.angle_to(point_b))
	func get_nearest_point(pos: Vector3) -> Vector3:
		var dir := body.global_position.direction_to(pos)
		var projected_dir := dir - dir.project(tilted_up_vector)
		return body.global_position + projected_dir * radius
	func get_orbital_move(om: OrbitalMovement, delta: float) -> Vector3:
		if not om in movements:
			return Vector3.ZERO
		var point := get_nearest_point(om.global_position) - body.global_position
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
		var v : float = dist_a / (dist_a + dist_b)
		var turn := Utility.clamp_map(v, 0, 1, -1, 1)
		var point := get_nearest_point(om.global_position) - body.global_position
		var correction := point.rotated(tilted_up_vector, \
							OrbitalMovementBody.CORRECTION_RPS * turn * delta)
		return correction - point

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

func _physics_process(delta: float) -> void:
	movement_process(VisualTime.visual_time_scale * delta)
