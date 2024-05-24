class_name GameCamera extends Node3D

var velocity := Vector3.ZERO
var rotation_input := 0.0
var rotation_input_vertical := 0.0
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

signal target_reached

var player_input_enabled := true
var follow_target: Node3D = null
var just_reach_target := false

@export var follow_damp_ease := 8.0
@export var follow_damp_range := 2.5
@export var target_reach_range := .2

func _ready() -> void:
	zoom_pivot.position.y = camera_zoom
	

# deprecated
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			#rotation_input += event.relative.x * mouse_rotation_factor * .5
			#rotation_input_vertical = - event.relative.y * mouse_rotation_factor

var relative_motion := Vector2(0.0, 0.0)


func _physics_process(delta: float) -> void:
	delta *= VisualTime.visual_time_scale
	
	# x-z movement
	if player_input_enabled:
		velocity += delta * move_acceleration * (basis * Vector3.RIGHT) * (Input.get_action_strength("move_camera_right") - Input.get_action_strength("move_camera_left"))
		velocity += delta * move_acceleration * (basis * Vector3.FORWARD) * (Input.get_action_strength("move_camera_forwards") - Input.get_action_strength("move_camera_backwards"))
		
	if follow_target != null:
		var dist := global_position.distance_to(follow_target.global_position)
		velocity += delta * move_acceleration * 1.6 * global_position.direction_to(follow_target.global_position)
		velocity *= pow(damping, delta)
		velocity *=  (1.0 - ease(Utility.clamp_map(dist, 0.0, follow_damp_range, 1.0, 0.0), follow_damp_ease))
		
		if just_reach_target and dist < target_reach_range:
			follow_target = null
			just_reach_target = false
			target_reached.emit()
	else:
		velocity *= pow(damping, delta)
	
	global_position += velocity * delta
		
	# rotation
	rotation_input += delta * rotation_velocity * (Input.get_action_strength("rotate_camera_clockwise") - Input.get_action_strength("rotate_camera_anticlockwise"))
	rotate_y(deg_to_rad(rotation_input))
	rotation_input = 0.0
	
	$AnglePivot.rotation_degrees.x = clamp($AnglePivot.rotation_degrees.x + rad_to_deg(delta * rotation_input_vertical), 5.0, 70.0)
	rotation_input_vertical = 0.0
	
	# zoom
	if Input.is_action_just_released("zoom_camera_out"):
		zoom_velocity += delta * zoom_factor
	elif Input.is_action_just_released("zoom_camera_in"):
		zoom_velocity -= delta * zoom_factor
	
	zoom_velocity *= pow(zoom_damping, delta)
	
	camera_zoom += zoom_velocity
	camera_zoom = clamp(camera_zoom, .80, 12.0)
	zoom_pivot.position.y = camera_zoom
	
	# mouse wheel pan
	if Input.is_action_pressed("mouse_pan"):
		rotation_input += relative_motion.x * mouse_rotation_factor * .5
		rotation_input_vertical = - relative_motion.y * mouse_rotation_factor

