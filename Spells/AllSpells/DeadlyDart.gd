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
	for enemy in target.get_enemies():
		enemy = enemy as EnemyEntity
		combat.animation.effect(VFX.BILLBOARD_PROJECTILE, combat.player.visual_entity, {"texture_name": spell.type.internal_name, "target": enemy.visual_entity})
		if enemy.get_status_effect("poison"):
			enemy.inflict_damage_with_visuals(99)
		else:
			#enemy.apply_status_effect(PoisonEffect.new(3))
			enemy.apply_status(Preloaded.STATUS_POISON)
