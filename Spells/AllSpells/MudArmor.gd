extends SpellLogic

## Usable references:
## spell - Corresponding spell
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created
## target - The target Tile (if Spell is targetable)

## The current costs with all the modifiers if there are any
#func _get_costs() -> EnergyStack:
	#return spell.type.costs

## This is for overriding if there are general cast-conditions
#func is_unlocked() -> bool:
	#return true

## This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true

## Here should be the effect
func casting_effect() -> void:
	combat.animation.effect(VFX.HEX_RINGS, combat.player.visual_entity, {"color": Color.SADDLE_BROWN}).set_max_duration(.5)
	combat.player.armor += 2
	combat.animation.update_hp(combat.player).set_flag_with()

