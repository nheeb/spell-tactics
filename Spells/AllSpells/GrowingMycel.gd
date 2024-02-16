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
#func _is_unlocked() -> bool:
	#return true

## This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true

const SHROOMS = preload("res://Entities/Environment/Shrooms.tres")
const FUNNEL = preload("res://Entities/Environment/FunnelShrooms.tres")

## Here should be the effect
func casting_effect() -> void:
	target = target as Tile
	var type = [SHROOMS, FUNNEL].pick_random()
	var shroom : Entity = combat.level.entities().create_entity(target.location, type, false)
	combat.animation.effect(VFX.HEX_RINGS, target, {"color": Color.DARK_VIOLET})
	combat.animation.show(shroom.visual_entity).set_flag_with()
	for i in range(2):
		combat.cards.draw()

