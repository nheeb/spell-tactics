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

## Here should be the effect
func casting_effect() -> void:
	target = target as Tile
	combat.animation.effect(VFX.BILLBOARD_EFFECT, target, {"grow_size": 2.0, "texture_name": "poison_cloud"})
	var enemies : Array[EnemyEntity] = []
	for tile in target.get_surrounding_tiles():
		tile = tile as Tile
		enemies.append_array(tile.get_enemies())
	for e in enemies:
		combat.animation.say(e.visual_entity,"Poisoned",{"color": Color.VIOLET}).set_duration(.2)
		#e.apply_status_effect(PoisonEffect.new(3))
		e.apply_status(Preloaded.STATUS_POISON)
