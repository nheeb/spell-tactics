class_name OrbitalMovement extends Node3D

## Orbital Movement consists of a mix of 9 types of movement:
## Gravity - Accelerating down
## Impulse - One Time Acceleration
## Damp - Reduce velocity
## Drag - Moving towards a Node3D
## Follow - Following along the orbits movement
## Bound - Binding to the orbit circle
## Correct - Get orbital distance to other Movements
## Push - Getting pushed away from other Movements
## Fixed - Getting moved to fixed points
## Each of them have an active variable float between 0 and 1

enum MovementType {
	Gravity, Impulse, Damp, Drag, Follow, Bound, Correct, Push, Fixed, Bezier
}

@onready var parent : Node3D = get_parent() as Node3D
@onready var pos : Vector3 = parent.global_position

var active_movements := {} # Movement Type -> Movement Objects
var orbit_body : OrbitalMovementBody
var attractor : EnergyOrbAttractor
var velocity := Vector3.ZERO

func setup_active_movements():
	active_movements[MovementType.Gravity] = MovementGravity.new(self)
	active_movements[MovementType.Impulse] = MovementImpulse.new(self)
	active_movements[MovementType.Damp] = MovementDamp.new(self)
	active_movements[MovementType.Drag] = MovementDrag.new(self)
	active_movements[MovementType.Follow] = MovementFollow.new(self)
	active_movements[MovementType.Bound] = MovementBound.new(self)
	active_movements[MovementType.Correct] = MovementCorrect.new(self)
	active_movements[MovementType.Push] = MovementPush.new(self)
	active_movements[MovementType.Fixed] = MovementFixed.new(self)
	active_movements[MovementType.Bezier] = MovementBezier.new(self)

func setup(_attractor, _orbit_body):
	attractor = _attractor
	if _orbit_body:
		attach_to_orbital_body(_orbit_body)
	setup_active_movements()

class Movement:
	var activation: float
	var om: OrbitalMovement
	func _init(_om: OrbitalMovement, _activation := 0.0) -> void:
		om = _om
		activation = _activation
	func get_speed(delta: float) -> Vector3:
		return _get_speed(delta) * activation if activation else Vector3.ZERO
	func _get_speed(delta: float) -> Vector3:
		return Vector3.ZERO
	func get_move(delta: float) -> Vector3:
		return _get_move(delta) * activation if activation else Vector3.ZERO
	func _get_move(delta: float) -> Vector3:
		return Vector3.ZERO

static var GRAVITY_DIRECTION := Vector3(0, -1, 0)
static var GRAVITY_FORCE := .12
class MovementGravity extends Movement:
	func _get_speed(delta: float) -> Vector3:
		return om.GRAVITY_DIRECTION * om.GRAVITY_FORCE * delta

class MovementImpulse extends Movement:
	var impulse := Vector3.ZERO
	func add_impulse(i: Vector3) -> void:
		impulse += i
	func _get_speed(delta: float) -> Vector3:
		if impulse != Vector3.ZERO:
			var i := impulse
			impulse = Vector3.ZERO
			return i
		else:
			return Vector3.ZERO

static var DAMP_LERP := .1
static var DAMP_MINIMAL := .001
class MovementDamp extends Movement:
	func _get_speed(delta: float) -> Vector3:
		if om.velocity.length() < om.DAMP_MINIMAL:
			return Vector3.ZERO
		var damped := om.velocity * pow(om.DAMP_LERP, delta)
		return damped - om.velocity

static var DRAG_FORCE := .4
class MovementDrag extends Movement:
	var drag_targets := {} # Node3D target -> float force 
	func _get_speed(delta: float) -> Vector3:
		var speed_change := Vector3.ZERO
		for target in drag_targets.keys():
			target = target as Node3D
			speed_change += om.global_position.direction_to(target.global_position) \
									* delta * om.DRAG_FORCE * drag_targets[target]
		return speed_change

class MovementFollow extends Movement:
	func _get_move(delta: float) -> Vector3:
		var body : OrbitalMovementBody = om.orbit_body
		return body.get_orbital_move(om, delta)

class MovementBound extends Movement:
	func _get_move(delta: float) -> Vector3:
		var body : OrbitalMovementBody = om.orbit_body
		return body.get_bound_move(om, delta)

class MovementCorrect extends Movement:
	func _get_move(delta: float) -> Vector3:
		var body : OrbitalMovementBody = om.orbit_body
		return body.get_correction_move(om, delta)

class MovementPush extends Movement:
	pass
	# TODO nitai add push movement

class MovementFixed extends Movement:
	var fixed_pos : Vector3
	func _get_move(delta: float) -> Vector3:
		return fixed_pos - om.global_position

signal bezier_finished
class MovementBezier extends Movement:
	var progress: float
	var duration: float = .6
	var p0: Vector3
	var p1: Vector3
	var p2: Vector3
	var node0: Node3D = null
	var node1: Node3D = null
	var node2: Node3D = null
	var active := false
	func start():
		active = true
		progress = 0.0
	func _get_move(delta: float) -> Vector3:
		if active:
			if node0: p0 = node0.global_position
			if node1: p1 = node1.global_position
			if node2: p2 = node2.global_position
			progress = min(1.0, progress + delta / duration)
			var eased_progress = ease(progress, 2.0)
			var pos : Vector3 = Utility.quadratic_bezier_3D(p0, p1, p2, eased_progress)
			if progress >= .99:
				finish()
			return pos - om.global_position
		else:
			return Vector3.ZERO
	func finish():
		active = false
		om.bezier_finished.emit()


###############
## Functions ##
###############

func attach_to_orbital_body(body: OrbitalMovementBody):
	if orbit_body:
		detach_from_orbital_body()
	orbit_body = body
	orbit_body.attach_movement(self)

func detach_from_orbital_body():
	if orbit_body:
		orbit_body.detach_movement(self)
		orbit_body = null

func jump(impulse: Vector3):
	active_movements[MovementType.Impulse].add_impulse(impulse)

static var BASE_JUMP_FORCE : float = .04
func base_jump():
	if attractor:
		jump(attractor.get_dir() * BASE_JUMP_FORCE)
		#print(attractor.get_dir() * BASE_JUMP_FORCE)
	else:
		jump(Vector3.UP * BASE_JUMP_FORCE)

const BEZIER_JUMP_LERP_DURATION = .3
func bezier_jump(x0, x1, x2, duration: float = .65):
	if x0 is Node3D:
		active_movements[MovementType.Bezier].node0 = x0
	else:
		active_movements[MovementType.Bezier].p0 = x0
	if x1 is Node3D:
		active_movements[MovementType.Bezier].node1 = x1
	else:
		active_movements[MovementType.Bezier].p1 = x1
	if x2 is Node3D:
		active_movements[MovementType.Bezier].node2 = x2
	else:
		active_movements[MovementType.Bezier].p2 = x2
	active_movements[MovementType.Bezier].duration = duration
	active_movements[MovementType.Bezier].start()
	VisualTime.create_tween().tween_property(self, "behaviour_bezier", \
				1.0, BEZIER_JUMP_LERP_DURATION)

@export var behaviour_fixed := true
@export var behaviour_fixed_progress := 0.0
@export var behaviour_physics := 0.0
@export var behaviour_orbit := 0.0
@export var behaviour_bezier := 0.0

func calculate_movement_activations(delta: float):
	for movement in active_movements.values():
		movement = movement as Movement
		movement.activation = 0.0
	if behaviour_fixed:
		active_movements[MovementType.Fixed].activation = 1.0
	else:
		active_movements[MovementType.Damp].activation = 1.0
		active_movements[MovementType.Push].activation = 1.0
		
		active_movements[MovementType.Gravity].activation = behaviour_physics
		active_movements[MovementType.Impulse].activation = behaviour_physics
		
		if orbit_body:
			var approaching_progress : float = orbit_body.get_orbit_approaching_progress(self)
			#print(approaching_progress)
			active_movements[MovementType.Drag].activation = behaviour_orbit * (1.0 - approaching_progress)
			active_movements[MovementType.Follow].activation = behaviour_orbit * approaching_progress
			active_movements[MovementType.Correct].activation = behaviour_orbit * approaching_progress
			active_movements[MovementType.Bound].activation = behaviour_orbit * approaching_progress

	if behaviour_bezier > 0.0:
		for movement in active_movements.values():
			movement = movement as Movement
			movement.activation *= 1.0 - behaviour_bezier
		active_movements[MovementType.Bezier].activation = behaviour_bezier

var last_move := Vector3.ZERO
func movement_process(delta: float) -> void:
	# Activations
	calculate_movement_activations(delta)
	
	# Fixed Progress
	if behaviour_fixed:
		if attractor:
			active_movements[MovementType.Fixed].fixed_pos = \
									attractor.get_pos(behaviour_fixed_progress)
	if behaviour_orbit:
		if orbit_body:
			active_movements[MovementType.Drag].drag_targets[orbit_body] = 1.0
	
	# General Movement
	var move := Vector3.ZERO
	for m in active_movements.values():
		m = m as Movement
		velocity += m.get_speed(delta)
		move += m.get_move(delta)
	move += velocity
	parent.global_position += move
	last_move = move
