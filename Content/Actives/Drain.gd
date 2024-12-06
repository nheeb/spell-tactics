extends ActiveLogic

func execute() -> void:
	await combat.action_stack.set_active_flavor(
		ActionFlavor.new().set_owner(combat.player)
			.add_tag(ActionFlavor.Tag.Drain)
			.add_target(target_tile)
			.add_target_array(target_tile.entities)
			.finalize(combat)
	)
	for entity in target_tile.entities:
		entity = entity as Entity
		if entity.is_drainable():
			combat.energy.gain(entity.energy, entity)
			await combat.action_stack.process_callable(entity.drain)
		elif entity.type.is_terrain: # not drainable terrain only gets drained visually
			combat.animation.callable(entity.visual_entity.visual_drain)

func is_target_valid(target: Variant, requirement: TargetRequirement) -> bool:
	return target.is_drainable()


func on_select_deselect(select: bool):
	super(select)
	for tile: Tile in active.current_possible_targets:
		tile.energy_popup.active = select or Game.ENERGY_OVERLAY
