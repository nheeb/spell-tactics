class_name OrbitalMovement extends Node3D

## Orbital Movement consists of a mix of 3 types of movement:
## Gravity - Accelerating down
## Impulse - One Time Acceleration
## Drag - Moving towards a Node3D
## Follow - Following the Orbiting points of the body
## Correct - Get orbital distance to other Movements
## Push - Getting pushed away from other Movements
## Each of them have an active variable float between 0 and 1

enum MovementType {
	Gravity, Impulse, Drag, Follow, Correct, Push
}

@onready var parent : Node3D = get_parent() as Node3D
@onready var pos : Vector3 = parent.global_position

var active_movements := {} # Movement Type -> Float [0.0 - 1.0]
var orbit_body : OrbitalMovementBody

var velocity := Vector3.ZERO

func setup_active_movements():
	active_movements[MovementType.Gravity] = MovementGravity.new(self)
	active_movements[MovementType.Impulse] = MovementImpulse.new(self)
	active_movements[MovementType.Drag] = MovementDrag.new(self)
	active_movements[MovementType.Follow] = MovementFollow.new(self)
	active_movements[MovementType.Correct] = MovementCorrect.new(self)
	active_movements[MovementType.Push] = MovementPush.new(self)

class Movement:
	var activation := 0.0
	var om: OrbitalMovement
	func _init(_om: OrbitalMovement) -> void:
		om = _om
	func get_speed(delta: float) -> Vector3:
		return _get_speed(delta) * activation if activation else Vector3.ZERO
	func _get_speed(delta: float) -> Vector3:
		return Vector3.ZERO
	func get_move(delta: float) -> Vector3:
		return _get_move(delta) * activation if activation else Vector3.ZERO
	func _get_move(delta: float) -> Vector3:
		return Vector3.ZERO

static var GRAVITY_DIRECTION := Vector3(0, -1, 0)
static var GRAVITY_FORCE := 2.0
class MovementGravity extends Movement:
	func _get_speed(delta: float) -> Vector3:
		return om.GRAVITY_DIRECTION * om.GRAVITY_FORCE * delta

class MovementImpulse extends Movement:
	var impulse := Vector3.ZERO
	func add_impulse(i: Vector3) -> void:
		impulse += i
	func _get_speed(delta: float) -> Vector3:
		var i := impulse
		impulse = Vector3.ZERO
		return i

static var DRAG_FORCE := 1.0
static var DRAG_MAX_VELOCITY := 2.0
class MovementDrag extends Movement:
	var drag_targets := {} # Node3D target -> float force 
	func _get_speed(delta: float) -> Vector3:
		var speed_change := Vector3.ZERO
		for target in drag_targets.keys():
			target = target as Node3D
			var target_velocity := om.global_position.direction_to(target.global_position) \
										* om.DRAG_MAX_VELOCITY
			speed_change += om.velocity.direction_to(target_velocity) * delta * om.DRAG_FORCE
		return speed_change

class MovementFollow extends Movement:
	func _get_move(delta: float) -> Vector3:
		var body : OrbitalMovementBody = om.orbit_body
		return body.get_orbital_move(om, delta)

class MovementCorrect extends Movement:
	pass

class MovementPush extends Movement:
	pass

func attach_to_orbital_body(body: OrbitalMovementBody):
	orbit_body = body
	orbit_body.attach_movement(self)

func detach_from_orbital_body():
	if orbit_body:
		orbit_body.detach_movement(self)
		orbit_body = null

