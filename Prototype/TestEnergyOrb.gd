extends Node3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("show_log"):
		test_spawn()

func test_spawn():
	for attractor in [$VisualRock/EnergyOrbAttractor, \
			$VisualRock/EnergyOrbAttractor2, $VisualRock/EnergyOrbAttractor3]:
		await VisualTime.new_timer(1).timeout
		var orb : EnergyOrb = VFX.ENERGY_ORB.instantiate() as EnergyOrb
		add_child(orb)
		orb._ready()
		orb.spawn($VisualPlayer/OrbitalMovementBody, attractor)

#func _ready() -> void:
	#for i in range(24):
		#var v = Vector3.FORWARD.rotated(Vector3.UP, i * TAU / 24)
		#print(v.signed_angle_to(Vector3.FORWARD, Vector3.UP))
