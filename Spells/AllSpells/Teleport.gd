extends SpellLogic

## Here should be the effect
func casting_effect() -> void:
	combat.movement.blink_entity(combat.player, target)

