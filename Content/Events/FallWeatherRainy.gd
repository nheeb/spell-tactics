extends CombatEventLogic

func _on_activate() -> void:
	for enemy in combat.enemies:
		enemy.apply_status(Preloaded.STATUS_WET)
	combat.player.apply_status(Preloaded.STATUS_WET)
	TimedEffect.new_flavor_reaction(
		ActionFlavor.new().set_owner(combat.player)\
			.add_tag(ActionFlavor.Tag.Drain)
			.finalize(combat),
		give_extra_harmony
	).set_id("rain_harmony").register(combat)

func _on_finish() -> void:
	var effects := combat.t_effects.get_effects(self, "rain_harmony")
	if not effects.is_empty():
		var effect = effects.front()
		if effect != null:
			effect.kill()

func give_extra_harmony():
	combat.energy.gain(EnergyStack.string_to_energy("H"), combat.player).set_flag_with()
	combat.animation.say(combat.player.visual_entity, "+1 Harmony from rain").set_flag_with()
