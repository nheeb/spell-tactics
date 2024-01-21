class_name GameCamera extends Node3D

var velocity := Vector3.ZERO
var rotation_input := 0.0
@export var move_acceleration := 30.0
## degrees per second
@export var rotation_velocity := 130.0
@export var damping := .02


@onready var zoom_pivot = $AnglePivot/ZoomPivot
var camera_zoom := 3.0
var zoom_velocity := 0.0
@export var zoom_factor := 5.0
@export var zoom_damping := 0.01
@export var mouse_rotation_factor := .3

var player_input_enabled := true
var follow_target: Node3D = null

func _ready() -> void:
	zoom_pivot.position.y = camera_zoom
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			rotation_input += event.relative.x * mouse_rotation_factor

func _physics_process(delta: float) -> void:
	# x-z movement
	if player_input_enabled:
		velocity += delta * move_acceleration * (basis * Vector3.RIGHT) * (Input.get_action_strength("move_camera_right") - Input.get_action_strength("move_camera_left"))
		velocity += delta * move_acceleration * (basis * Vector3.FORWARD) * (Input.get_action_strength("move_camera_forwards") - Input.get_action_strength("move_camera_backwards"))
	if follow_target != null:
		velocity += delta * move_acceleration * 1.6 * global_position.direction_to(follow_target.global_position)
	velocity *= pow(damping, delta)
	global_position += velocity * delta
		
	# rotation
	rotation_input += delta * rotation_velocity * (Input.get_action_strength("rotate_camera_clockwise") - Input.get_action_strength("rotate_camera_anticlockwise"))
	rotate_y(deg_to_rad(rotation_input))
	rotation_input = 0.0
	
	# zoom
	if Input.is_action_just_released("zoom_camera_out"):
		zoom_velocity += delta * zoom_factor
	elif Input.is_action_just_released("zoom_camera_in"):
		zoom_velocity -= delta * zoom_factor
	
	zoom_velocity *= pow(zoom_damping, delta)
	
	camera_zoom += zoom_velocity
	camera_zoom = clamp(camera_zoom, .80, 12.0)
	zoom_pivot.position.y = camera_zoom
