class_name EnergyOrb extends Node3D

func set_type(_type):
	$Orb.material_override.set("shader_parameter/albedo", VFX.type_to_color(_type))
	$OmniLight3D.light_color = VFX.type_to_color(_type)

@onready var movement : OrbitalMovement = $OrbitalMovement

func spawn(orbit_body, attractor = null):
	movement.setup(attractor, orbit_body)
	$AnimationPlayer.play("spawn")

func _ready() -> void:
	VisualTime.connect_animation_player($AnimationPlayer)

func _physics_process(delta: float) -> void:
	movement.movement_process(delta * VisualTime.visual_time_scale)
