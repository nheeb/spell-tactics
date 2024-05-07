class_name EnergyOrb extends Node3D

var type : int

func set_type(_type):
	type = _type
	$Orb.material_override.set("shader_parameter/albedo", VFX.type_to_color(_type))
	$OmniLight3D.light_color = VFX.type_to_color(_type)
	$Orb.material_override.next_pass.set("shader_parameter/texture_albedo", \
						VFX.type_to_icon(_type))

func get_type():
	return type

@onready var movement : OrbitalMovement = $OrbitalMovement

func spawn(orbit_body, attractor = null):
	movement.setup(attractor, orbit_body)
	$AnimationPlayer.play("spawn")

func _ready() -> void:
	VisualTime.connect_animation_player($AnimationPlayer)

func _process(delta: float) -> void:
	movement.movement_process(delta * VisualTime.visual_time_scale)

func death():
	$AnimationPlayer.play("death")

func delete():
	movement.detach_from_orbital_body()
	queue_free()
