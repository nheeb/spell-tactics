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
	assert(target is Array)
	combat.animation.wait(.8)
	for tile in target:
		tile = tile as Tile
		var dist = tile.distance_to(combat.player.current_tile)
		combat.animation.effect(VFX.BILLBOARD_EFFECT, tile, {"grow_size": 1.5, \
			 "texture_name": "steam", "duration": 1.2}).set_delay(.2 * dist).set_flag_with()
	
	for tile in target:
		for enemy in tile.get_enemies():
			enemy = enemy as EnemyEntity
			enemy.inflict_damage_with_visuals(1)
			enemy.apply_status_effect(WetEffect.new())

