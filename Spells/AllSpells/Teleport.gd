extends SpellLogic

func casting_effect() -> void:
	combat.movement.blink_entity(combat.player, target)
