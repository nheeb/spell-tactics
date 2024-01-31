extends SpellLogic

## Usable references:
## spell - Corresponding spell
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created
## target - The target Entity/Tile (if Spell is targetable)

## Here should be the effect
func casting_effect() -> void:
	combat.cards.draw()
	combat.cards.draw()
	combat.cards.draw()

