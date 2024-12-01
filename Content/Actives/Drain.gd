extends ActiveLogic

func execute() -> void:
	await combat.action_stack.set_active_flavor(
		ActionFlavor.new().set_owner(combat.player)
			.add_tag(ActionFlavor.Tag.Drain)
			.add_target(target_tile)
			.add_target_array(target_entities)
			.finalize(combat)
	)
	for entity in target_entities:
		entity = entity as Entity
		var energy_stack : EnergyStack = null
		if entity.is_drainable():
			entity.drain() # removes the energy and queues the visual drain animation
			energy_stack = entity.get_drained_energy()
			combat.energy.gain(energy_stack, entity)
		elif entity.type.is_terrain:  # terrain only gets drained visually
			combat.animation.callable(entity.visual_entity.visual_drain)

func is_target_valid(target: Variant, requirement: TargetRequirement) -> bool:
	return target.is_drainable()
