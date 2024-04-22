class_name EnergyOrb extends Node3D

func set_type(_type):
	$Orb.material_override.set("shader_parameter/albedo", VFX.type_to_color(_type))
	$OmniLight3D.light_color = VFX.type_to_color(_type)

@onready var movement : OrbitalMovement = $OrbitalMovement
