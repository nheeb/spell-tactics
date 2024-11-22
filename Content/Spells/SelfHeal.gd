extends SpellLogic

func casting_effect() -> void:
	combat.animation.effect(VFX.HEX_RINGS, combat.player.visual_entity, {"color": Color.GREEN})
	combat.animation.effect(VFX.ICON_BURST, combat.player.visual_entity, {"icon_name": "plus", "color": Color.GREEN}).set_flag_with()
	combat.player.inflict_heal_with_visuals(3).set_flag_with()
