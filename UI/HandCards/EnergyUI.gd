class_name EnergyUI extends Node3D

@onready var omb := $OrbitalMovementBody
@onready var attractor := $EnergyOrbAttractor

const ORB_DELAY : float = .35
const ORB_SCALE : float = 2.0
func spawn_energy_orbs(stack: EnergyStack):
	for i in range(stack.size()):
		var orbs_with_same_type := get_orbs().filter(
			func (orb: EnergyOrb): return orb.type == stack.stack[i]
		)
		if orbs_with_same_type:
			if orbs_with_same_type.size() != 1:
				push_error("Why are there more than one orb of the same type?")
			var orb = orbs_with_same_type.front() as EnergyOrb
			orb.energy_count += 1
		else:
			var orb = VFX.ENERGY_ORB.instantiate()
			omb.add_child(orb)
			orb.base_scale = ORB_SCALE
			orb.type = stack.stack[i]
			orb._ready()
			orb.spawn_in_ui(omb, attractor)
		await VisualTime.new_timer(ORB_DELAY).timeout

func _ready() -> void:
	$MeshInstance3D.hide()

func get_orbs() -> Array[EnergyOrb]:
	var orbs : Array[EnergyOrb] = []
	for c in omb.get_children():
		if c is EnergyOrb:
			orbs.append(c)
	return orbs
