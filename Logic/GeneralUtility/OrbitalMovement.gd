class_name OrbitalMovement extends Node3D

@onready var parent : Node3D = get_parent() as Node3D
#@onready var pos : Vector3 = parent.global_position

var free_target_pos : Vector3
var orbit_target_pos : Vector3
var orbit_body : OrbitalMovementBody

var orbit_lerp := .8
var free_lerp := .95

var jump_strength := 0.0
var jump_reduction := 2.0
var jump_speed := 1.0
var jump_direction : Vector3

func movement_process(delta: float) -> void:
	var current_pos := parent.global_position
	
	var lerp_pos : Vector3
	if orbit_body:
		lerp_pos = lerp(current_pos, orbit_target_pos, 1 - pow(1-orbit_lerp, delta))
	else:
		lerp_pos = lerp(current_pos, free_target_pos, 1 - pow(1-free_lerp, delta))
	
	jump_strength = max(0.0, jump_strength - jump_reduction * delta)
	var jump_pos := current_pos + jump_direction * jump_speed * delta
	
	var final_pos: Vector3 = lerp(lerp_pos, jump_pos, min(1.0, jump_strength))
	parent.global_position = final_pos

func attach_to_orbital_body(body: OrbitalMovementBody):
	orbit_body = body
	orbit_body.movements.append(self)

func detach_from_orbital_body():
	if orbit_body:
		orbit_body.movements.erase(self)
		orbit_body = null

func jump(direction: Vector3, strength: float = 1.0):
	jump_direction = direction
	jump_strength = strength

func detach_and_fly_to(pos: Vector3):
	detach_from_orbital_body()
	free_target_pos = pos
