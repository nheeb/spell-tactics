extends ActiveLogic

func casting_effect() -> void:
	for entity in target.entities:
		entity = entity as Entity
		var energy_stack : EnergyStack = null
		if entity.is_drainable():
			# entity.drain() removes the energy and queues the visual drain animation
			entity.drain()
			energy_stack = entity.get_drained_energy()
			combat.energy.gain(energy_stack, entity)
		for tag in entity.get_tags():
			combat.log.register_incident("drained_tag_%s" % tag)

func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	return _target.is_drainable()

