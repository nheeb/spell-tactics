extends SpellLogic

func casting_effect() -> void:
	combat.animation.effect(VFX.HEX_RINGS, combat.player.visual_entity, {"color": Color.SADDLE_BROWN}).set_max_duration(.5)
	combat.player.armor += 2
	combat.animation.update_hp(combat.player).set_flag_with()
