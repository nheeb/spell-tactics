extends ActiveLogic

func casting_effect() -> void:
	await combat.action_stack.set_active_flavor(
		ActionFlavor.new().set_owner(combat.player)
			.add_tag(ActionFlavor.Tag.Drain)
			.add_target(target_tile)
			.add_target_array(target_entities)
			.finalize(combat)
	)
	for entity in target.entities:
		entity = entity as Entity
		var energy_stack : EnergyStack = null
		if entity.is_drainable():
			entity.drain() # removes the energy and queues the visual drain animation
			energy_stack = entity.get_drained_energy()
			combat.energy.gain(energy_stack, entity)
		elif entity.type.is_terrain:  # terrain only gets drained visually
			combat.animation.callable(entity.visual_entity.visual_drain)

func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	return _target.is_drainable()
