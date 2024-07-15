extends CombatEventLogic

func _on_activate() -> void:
	# TODO Nitai make enemies wet
	TimedEffect.new_from_signal_and_callable(combat.log.cast, te_on_cast)\
		.set_owner(self).set_id("te").give_signal_params_as_parameter()\
		.register(combat)

func _on_finish() -> void:
	combat.t_effects.get_effects(self, "te").front().kill()

func te_on_cast(castable: Castable):
	if castable is Active and "Drain" in castable.get_type().internal_name:
		give_extra_harmony()

func give_extra_harmony():
	combat.energy.gain(EnergyStack.string_to_energy("H")).set_flag_with()
	combat.animation.say(combat.player.visual_entity, "+1 Harmony").set_flag_with()
