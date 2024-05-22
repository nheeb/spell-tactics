class_name EnergyUI extends Node3D

@onready var omb := $OrbitalMovementBody
@onready var attractor := $EnergyOrbAttractor

const ENERGY_ORB = preload("res://Effects/EnergyOrb.tscn")
const ORB_DELAY : float = .5
const ORB_SCALE : float = 2.0
func spawn_energy_orbs(stack: EnergyStack):
	for i in range(stack.size()):
		await VisualTime.new_timer(ORB_DELAY).timeout
		var orb = VFX.ENERGY_ORB.instantiate()
		omb.add_child(orb)
		orb.scale *= ORB_SCALE
		orb.set_type(stack.stack[i])
		orb._ready()
		orb.spawn_in_ui(omb, attractor)

func _ready() -> void:
	$MeshInstance3D.hide()
