extends SpellLogic

## Usable references:
## spell - Corresponding spell
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created
## target - The target Entity/Tile (if Spell is targetable)

## This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true

## Here should be the effect
func casting_effect() -> void:
	assert(target is Tile, "Melee expecting Tile as target")
	target = target as Tile
	var enemies = target.get_enemies()
	assert(len(enemies) >= 1, "Melee expects min 1 enemy on tile")
	enemies[0].inflict_damage(1 if not Game.DEBUG_SPELL_TESTING else 5)
	combat.animation.update_hp(enemies[0])
	combat.animation.say(combat.player.current_tile, "ATTACK!", {"color": Color.CORAL, "font": "bold"})

