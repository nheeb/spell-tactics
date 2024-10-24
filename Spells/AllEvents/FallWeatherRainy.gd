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
	).register(combat)

func _on_finish() -> void:
	# TODO what if game has already ended? (I got a null pointer here, don't know if my null check breaks something - Nils)
	var effects := combat.t_effects.get_effects(self, "te")
	if not effects.is_empty():
		var effect = effects.front()
		if effect != null:
			effect.kill()

func te_on_cast(castable: Castable):
	if castable is Active and "Drain" in castable.get_type().internal_name:
		give_extra_harmony()

func give_extra_harmony():
	combat.energy.gain(EnergyStack.string_to_energy("H"), combat.player).set_flag_with()
	combat.animation.say(combat.player.visual_entity, "+1 Harmony from rain").set_flag_with()
