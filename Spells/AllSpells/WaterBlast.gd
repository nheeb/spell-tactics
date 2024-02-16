extends SpellLogic

## Usable references:
## spell - Corresponding spell
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created
## target - The target Entity/Tile (if Spell is targetable)

## The current costs with all the modifiers if there are any
#func _get_costs() -> Array[Game.Energy]:
	#return spell.type.costs

## This is for overriding if there are general cast-conditions
#func _is_unlocked() -> bool:
	#return true

## This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true

## Here should be the effect
func casting_effect() -> void:
	assert(target is Tile, "WaterBlast expecting Tile as target")
	target = target as Tile
	var enemies = target.get_enemies()
	assert(len(enemies) >= 1, "WaterBlast expects min 1 enemy on tile")
	
	for enemy in enemies:
		enemy = enemy as EnemyEntity
		enemy.inflict_damage_with_visuals(3)
		enemy.apply_status_effect(WetEffect.new())
		combat.movement.apply_knockback(enemy, \
				combat.player.current_tile.direction_to(enemy.current_tile), 2)

