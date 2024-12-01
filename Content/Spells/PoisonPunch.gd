extends SpellLogic

func execute() -> void:
	combat.player.apply_status(Preloaded.STATUS_POISON_MELEE)
