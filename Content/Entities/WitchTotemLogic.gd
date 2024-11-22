extends EntityLogic

func on_summon():
	TimedEffect.new_flavor_reaction(
		ActionFlavor.new()
			.add_tag(ActionFlavor.Tag.Spell)
			.finalize(combat),
		give_energy
	).register(combat)

func give_energy() -> void:
	if combat.player.current_tile.distance_to(entity.current_tile) <= 1:
		combat.animation.camera_reach(entity.visual_entity)
		combat.animation.effect(VFX.HEX_RINGS, entity.visual_entity, {"color": Color.DARK_VIOLET}).set_max_duration(.5)
		combat.energy.gain(EnergyStack.string_to_energy("D"), entity).set_flag_with()
		combat.animation.say(entity.visual_entity, "+1 Decay").set_flag_with()
