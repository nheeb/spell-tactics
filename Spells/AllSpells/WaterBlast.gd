extends SpellLogic

## Here should be the effect
func casting_effect() -> void:
	assert(target is Tile, "WaterBlast expecting Tile as target")
	target = target as Tile
	var enemies = target.get_enemies()
	assert(len(enemies) >= 1, "WaterBlast expects min 1 enemy on tile")
	
	for enemy in enemies:
		enemy = enemy as EnemyEntity
		enemy.inflict_damage_with_visuals(3)
		#enemy.apply_status_effect(WetEffect.new())
		enemy.apply_status(Preloaded.STATUS_WET)
		combat.movement.apply_knockback(enemy, \
				combat.player.current_tile.direction_to(enemy.current_tile), 2)
