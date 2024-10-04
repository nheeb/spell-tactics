extends EntityLogic

func on_summon():
	TimedEffect.new_from_signal_and_callable(
		combat.spell_casted_successfully, give_energy
	).register(combat)

var first_time_lock := true

func give_energy(spell_ref = null) -> void:
	if first_time_lock:
		first_time_lock = false
		return
	if combat.player.current_tile.distance_to(entity.current_tile) <= 1:
		combat.animation.camera_reach(entity.visual_entity)
		combat.animation.effect(VFX.HEX_RINGS, entity.visual_entity, {"color": Color.DARK_VIOLET}).set_max_duration(.5)
		combat.energy.gain(EnergyStack.string_to_energy("D")).set_flag_with()
		combat.animation.say(entity.visual_entity, "+1 Decay").set_flag_with()
