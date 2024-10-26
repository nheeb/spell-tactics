extends SpellLogic

func casting_effect() -> void:
	combat.player.apply_status(Preloaded.STATUS_POISON_MELEE)
