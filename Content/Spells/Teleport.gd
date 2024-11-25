extends SpellLogic

func execute() -> void:
	combat.movement.blink_entity(combat.player, target)
